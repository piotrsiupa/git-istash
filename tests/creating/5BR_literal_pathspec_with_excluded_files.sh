. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'xxx\n' >'a1'
printf 'xxx\n' >'a2'
printf 'xxx\n' >'b1'
printf 'xxx\n' >'b2'
printf 'xxx\n' >':(exclude)*1'
printf 'xxx\n' >'b?'
printf ':(exclude)*1 b? ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git --literal-pathspecs istash push $KEEP_INDEX_FLAGS $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS ":(exclude)*1" $ALL_FLAGS $EOI 'b?'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	GIT_LITERAL_PATHSPECS=1 assert_exit_code 0 git istash push $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	GIT_LITERAL_PATHSPECS=yes assert_exit_code 0 git istash push $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
assert_files_H '
?? a1		xxx
?? a2		xxx
?? b1		xxx
?? b2		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_H 0 '' '
?? :(exclude)*1	xxx
?? b?		xxx
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
?? a1		xxx
?? a2		xxx
?? b1		xxx
?? b2		xxx
?? :(exclude)*1	xxx
?? b?		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
