. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
if ! IS_PATHSPEC_NULL_SEP
then
	printf 'ignored0 ignored1 ' | tr ' ' '\n' >.git/pathspec_for_test
else
	printf 'ignored0 ignored1 ' | tr ' ' '\0' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash push $KEEP_INDEX_FLAGS $UNTRACKED_FLAGS $ALL_FLAGS $EOI 'ignored0' 'ignored1'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
assert_files_H '
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
assert_branch_metadata_H
