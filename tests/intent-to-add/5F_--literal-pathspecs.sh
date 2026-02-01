. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'This test requires a file system without limitations for file names.'
fi

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX 'DEFAULT' 'YES'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS
PARAMETRIZE_COLOR NO  # Randomly chosen value

__end_of_initialization__

prepare_repository

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'xxx\n' >'f*'
printf 'xxx\n' >'foo'
printf 'xxx\n' >'bar'
printf 'xxx\n' >'x*'
printf 'xxx\n' >'xxx'
printf 'xxx\n' >'y*'
printf 'xxx\n' >'yyy'
git add --intent-to-add .
printf 'f* x* y* ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git --literal-pathspecs istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $COLOR_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'new stash' $EOI 'f*' 'x*' 'y*'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git --literal-pathspecs istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $COLOR_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS "$PATHSPEC_FROM_FILE_FLAG"=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git --literal-pathspecs istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $COLOR_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS "$PATHSPEC_FROM_FILE_FLAG" .git/pathspec_for_test
fi
assert_outputs__create__success '*' 0 'new stash'
new_stash_sha_CO="$stdout"
assert_files_HTCO '
 A f*		xxx
 A foo		xxx
 A bar		xxx
 A x*		xxx
 A xxx		xxx
 A yyy		xxx
 A y*		xxx
!! ignored0	ignored0
!! ignored1	ignored1
' '
 A foo		xxx
 A bar		xxx
 A xxx		xxx
 A yyy		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 'new stash' '
 A f*		xxx
 A x*		xxx
 A y*		xxx
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash pop $COLOR_FLAGS
assert_outputs__apply__success 'pop' 0 "$stash_sha"
assert_files '
 A f*		xxx
 A x*		xxx
 A y*		xxx
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
