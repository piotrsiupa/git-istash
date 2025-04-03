. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'NO'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED 'NO'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa\n' >'aaa'
git add aaa
if ! IS_PATHSPEC_NULL_SEP
then
	printf 'aaa ' | tr ' ' '\n' >.git/pathspec_for_test
else
	printf 'aaa ' | tr ' ' '\0' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash push $KEEP_INDEX_FLAGS 'aaa' $UNTRACKED_FLAGS $ALL_FLAGS -m 'whatever' $UNSTAGED_FLAGS $STAGED_FLAGS $EOI
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'whatever' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- $UNSTAGED_FLAGS $STAGED_FLAGS <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'whatever' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test $UNSTAGED_FLAGS $STAGED_FLAGS
fi
assert_files_H '
A  aaa		aaa
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
assert_dotgit_contents
