. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

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
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash apply
assert_conflict_message git istash apply
assert_files_H '
UU aaa		ccc|bbb
!! ignored	ignored
' '
DU aaa		bbb
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files 'apply'
assert_rebase y

__test_section__ 'Continue applying stash (0)'
correct_head_hash2="$(get_head_hash_H)"
printf 'ddd\n' >aaa
git add aaa
mv .git/ISTASH_TARGET .git/ISTASH_TARGET~
printf 'fa4e08a58\n' >.git/ISTASH_TARGET
assert_exit_code 1 git istash apply --continue
assert_files_H '
M  aaa		ddd
!! ignored	ignored
' '
A  aaa		ddd
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_head_hash_H "$correct_head_hash2"
assert_data_files 'apply'
assert_rebase y

__test_section__ 'Continue applying stash (1)'
mv .git/ISTASH_TARGET~ .git/ISTASH_TARGET
assert_exit_code 0 git istash apply --continue
assert_files_H '
 M aaa		ddd	ccc
!! ignored	ignored
' '
?? aaa		ddd
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
