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
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'xxx\n' >'abcde'
printf 'xxx\n' >'a???e'
printf 'xxx\n' >'a*e'
printf 'xxx\n' >'xyz'
printf ':(literal)a???e :(literal)a*e ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS ':(literal)a???e' $ALL_FLAGS $EOI ':(literal)a*e'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
assert_outputs__create__success
new_stash_sha_CO="$stdout"
assert_files_HTCO '
?? abcde	xxx
?? a???e	xxx
?? a*e		xxx
?? xyz		xxx
!! ignored0	ignored0
!! ignored1	ignored1
' '
?? abcde	xxx
?? xyz		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
?? a???e	xxx
?? a*e		xxx
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
assert_exit_code 0 git stash pop --index
assert_files '
?? a???e	xxx
?? a*e		xxx
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
