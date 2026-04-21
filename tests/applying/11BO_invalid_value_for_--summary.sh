. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_COLOR

__end_of_initialization__

prepare_repository

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'ddd\n' >ddd
git stash push -ua

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 1 git istash "$APPLY_OPERATION" $COLOR_FLAGS --summary='maybe-or-maybe-not'
assert_outputs__apply__bad_summary_mode_in_flag 'maybe-or-maybe-not'
assert_files_HT '
   aaa		aaa
'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
