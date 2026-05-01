. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_QUIT
PARAMETRIZE_COLOR
PARAMETRIZE_QUIET

__end_of_initialization__

prepare_repository

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add --intent-to-add aaa
git istash push

__test_section__ 'Create conflict'
printf 'bbb\n' >aaa
git add aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
#shellcheck disable=SC2086
assert_exit_code 2 git istash $QUIET_FLAGS "$APPLY_OPERATION" $COLOR_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 2 '
AA aaa
'
assert_files_HT '
AA aaa		bbb|aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Quit $APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash $QUIET_FLAGS "$APPLY_OPERATION" $COLOR_FLAGS "$QUIT_FLAG"
assert_outputs__apply__quit "$APPLY_OPERATION"
assert_files_HT '
AA aaa		bbb|aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_head_sha_HT "$correct_head_sha"
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents_for 'none'
