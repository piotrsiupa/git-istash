. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_ABORT

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git stash push -u

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory & create conflict'
printf 'ddd\n' >aaa
git add aaa

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
assert_exit_code 2 git istash "$APPLY_OPERATION"
assert_outputs__apply__conflict "$APPLY_OPERATION" '
AA aaa
'
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
AA aaa		ddd|bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Abort $APPLY_OPERATION stash"
assert_exit_code 0 git istash "$APPLY_OPERATION" "$ABORT_FLAG"
assert_outputs__apply__abort "$APPLY_OPERATION"
assert_files_HT '
A  aaa		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
