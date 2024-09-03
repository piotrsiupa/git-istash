. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH'

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git stash push

__test_section__ 'Create conflict'
printf 'ccc\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ 'Apply stash'
assert_exit_code 2 capture_outputs git istash apply
assert_conflict_message git istash apply
assert_files_H '
UU aaa		ccc|bbb
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'apply'
assert_rebase y

__test_section__ 'Continue applying stash'
printf 'ddd\n' >aaa
git add aaa
mv '.git/ISTASH_TARGET' '.git/ISTASH_TARGET~'
{ printf '~' ; cat '.git/ISTASH_TARGET~' ; } >'.git/ISTASH_TARGET'
assert_exit_code 1 git istash apply --continue
assert_file_contents ignored 'ignored'
