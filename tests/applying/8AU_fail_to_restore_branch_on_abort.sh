. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH'
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
correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 2 capture_outputs git istash "$OPERATION"
assert_conflict_message
assert_files_H '
UU aaa		ccc|bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count 1
assert_data_files "$OPERATION"
assert_rebase y
assert_dotgit_contents_for "$OPERATION"

__test_section__ "Abort $OPERATION stash (0)"
master_hash="$(git rev-parse master)"
git branch -D master
assert_exit_code 1 git istash "$OPERATION" --abort
assert_all_files 'aaa|ignored0|ignored1'
assert_file_contents ignored0 'ignored0'
assert_file_contents ignored1 'ignored1'
assert_stash_count 1
assert_branch_count 0
assert_data_files "$OPERATION"
assert_rebase y
assert_dotgit_contents_for "$OPERATION"

__test_section__ "Abort $OPERATION stash (1)"
git branch master "$master_hash"
if IS_HEAD_BRANCH
then
	git branch --set-upstream-to='my-origin/my-branch' master
fi
assert_exit_code 0 git istash "$OPERATION" --abort
assert_files_H '
   aaa		ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
