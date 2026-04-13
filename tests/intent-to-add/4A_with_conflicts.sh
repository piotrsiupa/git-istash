. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_CONTINUE
PARAMETRIZE_COLOR
PARAMETRIZE_SUMMARY

__end_of_initialization__

prepare_repository

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add --intent-to-add aaa
git istash push

__test_section__ 'Create conflict'
printf 'bbb\n' >aaa
git add aaa
git commit -m 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $COLOR_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" '
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

__test_section__ "Continue $APPLY_OPERATION stash"
printf 'ccc\n' >aaa
git add aaa
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$APPLY_OPERATION" $COLOR_FLAGS $SUMMARY_FLAGS "$CONTINUE_FLAG"
assert_outputs__apply__success "$APPLY_OPERATION" '
 M aaa
' 0 "$stash_sha"
assert_files_HT '
 M aaa		ccc	bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
