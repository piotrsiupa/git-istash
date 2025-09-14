. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_ABORT

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

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(git rev-parse HEAD)"
assert_exit_code 2 capture_outputs git istash "$APPLY_OPERATION"
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU aaa		ccc|bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Abort $APPLY_OPERATION stash (0)"
master_sha="$(git rev-parse master)"
git branch -D master
assert_exit_code 1 git istash "$APPLY_OPERATION" "$ABORT_FLAG"
assert_all_files 'aaa|ignored0|ignored1'
assert_file_contents ignored0 'ignored0'
assert_file_contents ignored1 'ignored1'
assert_stash_count 1
assert_branch_count 0
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Abort $APPLY_OPERATION stash (1)"
git branch master "$master_sha"
if IS_HEAD_BRANCH
then
	git branch --set-upstream-to='my-origin/my-branch' master
fi
assert_exit_code 0 git istash "$APPLY_OPERATION" "$ABORT_FLAG"
assert_files_HT '
   aaa		ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 3
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
