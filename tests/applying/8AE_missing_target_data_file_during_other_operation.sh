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

__test_section__ "$CAP_OTHER_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash $OTHER_OPERATION
assert_conflict_message git istash $OTHER_OPERATION
assert_files_H '
UU aaa		ccc|bbb
!! ignored	ignored
' '
DU aaa		bbb
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files "$OTHER_OPERATION"
assert_rebase y

__test_section__ "Continue $OPERATION stash (0)"
correct_head_hash2="$(get_head_hash_H)"
printf 'ddd\n' >aaa
git add aaa
mv .git/ISTASH_TARGET .git/ISTASH_TARGET~
assert_exit_code 1 git istash "$OPERATION" --continue
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
assert_rebase y

__test_section__ "Continue $OTHER_OPERATION stash (1)"
mv .git/ISTASH_TARGET~ .git/ISTASH_TARGET
assert_exit_code 0 git istash $OTHER_OPERATION --continue
assert_files_H '
 M aaa		ddd	ccc
!! ignored	ignored
' '
?? aaa		ddd
!! ignored	ignored
'
if IS_APPLY
then
	assert_stash_count 0
else
	assert_stash_count 1
fi
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
