. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_CONTINUE
PARAMETRIZE_COLOR
PARAMETRIZE_QUIET
PARAMETRIZE_SUMMARY

__end_of_initialization__

prepare_repository

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
git rm aaa
printf 'bbb\n' >aaa
git add --intent-to-add aaa
git istash push

__test_section__ 'Create conflict'
printf 'ccc\n' >aaa
git add aaa
git commit -m 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $COLOR_FLAGS $QUIET_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 0 '
UD aaa
'
assert_files_HT '
UD aaa		ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (0)"
git add aaa
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $COLOR_FLAGS "$CONTINUE_FLAG" $QUIET_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 2 '
AA aaa
'
assert_files_HT '
AA aaa		ccc|bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (1)"
printf 'ddd\n' >aaa
git add aaa
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$APPLY_OPERATION" $SUMMARY_FLAGS $COLOR_FLAGS "$CONTINUE_FLAG" $QUIET_FLAGS
assert_outputs__apply__success "$APPLY_OPERATION" '
 M aaa
' 0 "$stash_sha"
assert_files_HT '
 M aaa		ddd	ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 3
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
