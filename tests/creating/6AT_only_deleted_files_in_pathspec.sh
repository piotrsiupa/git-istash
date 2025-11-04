. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'NO'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

__test_section__ 'Prepare repository'
printf 'xxx\n' >aaa
printf 'xxx\n' >bbb
printf 'xxx\n' >ccc
printf 'xxx\n' >ddd
printf 'xxx\n' >eee
printf 'xxx\n' >fff
git add .
git commit -m 'Added some files'

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
rm aaa bbb
git rm ccc ddd
if ! IS_PATHSPEC_NULL_SEP
then
	printf 'bbb ddd '
else
	printf 'bbb ddd'
fi | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $EOI 'bbb' 'ddd'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
assert_outputs__create__success
new_stash_sha_CO="$stdout"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	 D aaa		xxx
	 D bbb		xxx
	D  ccc
	D  ddd
	   eee		xxx
	   fff		xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	 D aaa		xxx
	   bbb		xxx
	D  ccc
	   ddd		xxx
	   eee		xxx
	   fff		xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HTCO '
	 D aaa		xxx
	 D bbb		xxx
	D  ccc
	D  ddd
	   eee		xxx
	   fff		xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	 D aaa		xxx
	   bbb		xxx
	D  ccc
	D  ddd
	   eee		xxx
	   fff		xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
   aaa		xxx
 D bbb		xxx
   ccc		xxx
D  ddd
   eee		xxx
   fff		xxx
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 2
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
   aaa		xxx
 D bbb		xxx
   ccc		xxx
D  ddd
   eee		xxx
   fff		xxx
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
