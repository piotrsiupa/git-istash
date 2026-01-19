. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_QUIT
PARAMETRIZE_COLOR YES  # Randomly chosen value

__end_of_initialization__

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
git stash push -m 'the only stash'

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory'
printf 'wdf0a\n' >wdf0
git add wdf0
printf 'wdf0b\n' >wdf0
printf 'wdf1a\n' >wdf1

__test_section__ "Quit $APPLY_OPERATION stash (without changes)"
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 1 git istash "$APPLY_OPERATION" $COLOR_FLAGS "$QUIT_FLAG"
assert_outputs__apply__no_operation_in_progress "istash $APPLY_OPERATION"
assert_files_HT '
AM wdf0		wdf0b	wdf0a
?? wdf1		wdf1a
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

__test_section__ "Quit $APPLY_OPERATION stash (with changes)"
printf 'ccc\n' >aaa
git add aaa
printf 'ddd\n' >aaa
#shellcheck disable=SC2086
assert_exit_code 1 git istash "$APPLY_OPERATION" $COLOR_FLAGS "$QUIT_FLAG"
assert_outputs__apply__no_operation_in_progress "istash $APPLY_OPERATION"
assert_files_HT '
AM aaa		ddd	ccc
AM wdf0		wdf0b	wdf0a
?? wdf1		wdf1a
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
