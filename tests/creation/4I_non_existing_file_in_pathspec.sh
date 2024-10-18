. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

if IS_OPTIONS_INDICATOR_ON
then
	known_failure 'Standard implementation of "git stash" does not adhere to the POSIX utility convention.'
fi
known_failure 'Standard implementation creates a stash despite failing to match the pathspec and returning 1.'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'xxx\n' >'aaa'
printf 'xxx\n' >'ccc'
printf 'xxx\n' >'ddd'

if ! IS_PATHSPEC_NULL_SEP
then
	printf 'aaa bbb ccc ' | tr ' ' '\n' >.git/pathspec_for_test
else
	printf 'aaa bbb ccc ' | tr ' ' '\0' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	assert_exit_code 1 git istash push $KEEP_INDEX_FLAGS 'aaa' $UNTRACKED_FLAGS 'bbb' $ALL_FLAGS -m 'new stash' $EOI 'ccc'
elif IS_PATHSPEC_IN_STDIN
then
	assert_exit_code 1 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else                                                                                     
	assert_exit_code 1 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
assert_files_H '
?? aaa		xxx
?? ccc		xxx
?? ddd		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
