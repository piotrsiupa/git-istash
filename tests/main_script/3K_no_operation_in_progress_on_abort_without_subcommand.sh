. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ABORT
PARAMETRIZE_COLOR NO  # Randomly chosen value

__end_of_initialization__

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
git stash push -m 'the only stash'

SWITCH_HEAD_TYPE

__test_section__ "Abort stash (without changes)"
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 1 git istash $COLOR_FLAGS "$ABORT_FLAG"
assert_outputs__main_script__no_operation_in_progress
assert_files_HT '
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
assert_dotgit_contents

__test_section__ "Abort stash (with changes)"
printf 'ccc\n' >aaa
git add aaa
printf 'ddd\n' >aaa
#shellcheck disable=SC2086
assert_exit_code 1 git istash "$ABORT_FLAG" $COLOR_FLAGS
assert_outputs__main_script__no_operation_in_progress
assert_files_HT '
AM aaa		ddd	ccc
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
