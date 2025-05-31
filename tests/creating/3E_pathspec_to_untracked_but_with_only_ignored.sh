. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'NO'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED
PARAMETRIZE_UNSTAGED
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa\n' >'aaa'
printf 'aaa ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash push $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS 'aaa' $UNTRACKED_FLAGS $ALL_FLAGS -m 'whatever' $EOI
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'whatever' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'whatever' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
assert_files_HT '
?? aaa		aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
