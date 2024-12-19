. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'NO'
PARAMETRIZE_KEEP_INDEX
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

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
rm aaa bbb
git rm ccc ddd
if ! IS_PATHSPEC_NULL_SEP
then
	printf 'bbb ddd fff ' | tr ' ' '\n' >.git/pathspec_for_test
else
	printf 'bbb ddd fff' | tr ' ' '\0' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $EOI 'bbb' 'ddd' 'fff'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
if ! IS_KEEP_INDEX_ON
then
	assert_files_H '
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
	assert_files_H '
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
assert_stash_H 0 '' '
   aaa		xxx
 D bbb		xxx
   ccc		xxx
D  ddd
   eee		xxx
   fff		xxx
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
assert_branch_metadata_H

git reset --hard
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
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_H
