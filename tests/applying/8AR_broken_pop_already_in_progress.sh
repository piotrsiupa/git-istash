. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP

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

__test_section__ 'Pop stash'
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash pop
assert_conflict_message
assert_files_H '
UU aaa		ccc|bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
DU aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files 'pop'
assert_rebase y

if IS_APPLY
then
	__test_section__ 'Apply stash'
else
	__test_section__ 'Pop stash again'
fi
mv .git/ISTASH_TARGET .git/ISTASH_TARGET~
correct_head_hash2="$(get_head_hash_H)"
printf 'ddd\n' >aaa
git add aaa
assert_exit_code 1 git istash "$OPERATION"
assert_files_H '
M  aaa		ddd
!! ignored0	ignored0
!! ignored1	ignored1
' '
A  aaa		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_H 1
assert_head_hash_H "$correct_head_hash2"
assert_rebase y

__test_section__ 'Abort popping stash'
mv .git/ISTASH_TARGET~ .git/ISTASH_TARGET
assert_exit_code 0 git istash pop --abort
assert_files_H '
   aaa		ccc
!! ignored0	ignored0
!! ignored1	ignored1
' '
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
