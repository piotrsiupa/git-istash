. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

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

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash "$OPERATION"
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
assert_data_files "$OPERATION"
assert_rebase y
assert_dotgit_contents_for "$OPERATION"

__test_section__ "Continue & abort $OPERATION stash"
correct_head_hash2="$(get_head_hash_H)"
assert_exit_code 1 git istash "$OPERATION" --continue --abort
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
assert_head_hash_H "$correct_head_hash2"
assert_data_files "$OPERATION"
assert_rebase y
assert_dotgit_contents_for "$OPERATION"

__test_section__ "Abort $OPERATION stash"
assert_exit_code 0 git istash "$OPERATION" --abort
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
assert_branch_metadata_H
assert_dotgit_contents
