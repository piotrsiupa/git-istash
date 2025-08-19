. "$commons_path" 1>/dev/null

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'This test requires a file system without limitations for file names.'
fi

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX 'DEFAULT' 'YES'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

__test_section__ 'Prepare repository'
printf 'xxx\n' >'f*'
printf 'xxx\n' >'foo'
printf 'xxx\n' >'bar'
printf 'xxx\n' >'x*'
printf 'xxx\n' >'xxx'
git add .
git commit -m 'Added a few files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'yyy\n' >'f*'
printf 'yyy\n' >'foo'
printf 'yyy\n' >'bar'
git add .
printf 'yyy\n' >'x*'
printf 'yyy\n' >'xxx'
printf 'yyy\n' >'y*'
printf 'yyy\n' >'yyy'
printf 'f* x* y* ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	new_stash_hash_CO="$(assert_exit_code 0 git --literal-pathspecs istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'new stash' $EOI 'f*' 'x*' 'y*')"
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	new_stash_hash_CO="$(assert_exit_code 0 git --literal-pathspecs istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test)"
else
	#shellcheck disable=SC2086
	new_stash_hash_CO="$(assert_exit_code 0 git --literal-pathspecs istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test)"
fi
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	M  f*		yyy
	M  foo		yyy
	M  bar		yyy
	 M x*		yyy	xxx
	 M xxx		yyy	xxx
	?? yyy		yyy
	?? y*		yyy
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	   f*		xxx
	M  foo		yyy
	M  bar		yyy
	   x*		xxx
	 M xxx		yyy	xxx
	?? yyy		yyy
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HTCO '
	M  f*		yyy
	M  foo		yyy
	M  bar		yyy
	 M x*		yyy	xxx
	 M xxx		yyy	xxx
	?? yyy		yyy
	?? y*		yyy
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	M  f*		yyy
	M  foo		yyy
	M  bar		yyy
	   x*		xxx
	 M xxx		yyy	xxx
	?? yyy		yyy
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 'new stash' '
M  f*		yyy
   foo		xxx
   bar		xxx
 M x*		yyy	xxx
   xxx		xxx
?? y*		yyy
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
M  f*		yyy
   foo		xxx
   bar		xxx
 M x*		yyy	xxx
   xxx		xxx
?? y*		yyy
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
