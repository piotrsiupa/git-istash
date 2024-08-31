. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'ORPHAN'

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
git stash push

SWITCH_HEAD_TYPE

assert_exit_code 2 capture_outputs git istash pop
assert_conflict_message git istash pop
assert_files_H '
DU aaa		bbb
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'pop'
assert_rebase y

printf 'ccc\n' >aaa
git add aaa
printf 'zzz\n' >zzz
git add zzz
git commit --amend --no-edit -- zzz
assert_exit_code 1 git istash pop --continue
assert_file_contents ignored 'ignored'
