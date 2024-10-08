. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

known_failure 'There is a bug in Git which makes it disregard pathspec for files in index.'
if IS_OPTIONS_INDICATOR_ON
then
	known_failure 'Standard implementation of "git stash" does not adhere to the POSIX utility convention.'
fi

__test_section__ 'Prepare repository'
printf 'xxx\n' >aaa0
printf 'xxx\n' >aaa1
printf 'xxx\n' >bbb2
printf 'xxx\n' >bbb3
printf 'xxx\n' >ccc4
printf 'xxx\n' >ccc5
printf 'xxx\n' >ddd6
printf 'xxx\n' >ddd7
printf 'xxx\n' >eee8
printf 'xxx\n' >eee9
git add .
git commit -m 'Added a bunch of files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'yyy\n' >aaa0
printf 'yyy\n' >aaa1
printf 'yyy\n' >bbb2
printf 'yyy\n' >bbb3
printf 'yyy\n' >ccc4
printf 'yyy\n' >ccc5
printf 'yyy\n' >ddd6
printf 'yyy\n' >ddd7
printf 'yyy\n' >eee8
printf 'yyy\n' >eee9
git add aaa0 bbb2 ccc4 ddd6 eee8

if ! IS_PATHSPEC_NULL_SEP
then
	printf 'aaa0 bbb? *5 ./?dd* ' | tr ' ' '\n' >.git/pathspec_for_test
else
	printf 'aaa0 bbb? *5 ./?dd* ' | tr ' ' '\0' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	assert_exit_code 0 git istash push 'aaa0' $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS 'bbb?' -m 'new stash' $EOI '*5' './?dd*'
elif IS_PATHSPEC_IN_STDIN
then
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
if ! IS_KEEP_INDEX_ON
then
	assert_files_H '
	   aaa0		xxx
	 M aaa1		yyy	xxx
	   bbb2		xxx
	   bbb3		xxx
	M  ccc4		yyy
	   ccc5		xxx
	   ddd6		xxx
	   ddd7		xxx
	M  eee8		yyy
	 M eee9		yyy	xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_H '
	M  aaa0		yyy
	 M aaa1		yyy	xxx
	M  bbb2		yyy
	   bbb3		xxx
	M  ccc4		yyy
	   ccc5		xxx
	M  ddd6		yyy
	   ddd7		xxx
	M  eee8		yyy
	 M eee9		yyy	xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_H 0 'new stash' '
M  aaa0		yyy
   aaa1		xxx
M  bbb2		yyy
 M bbb3		yyy	xxx
   ccc4		xxx
 M ccc5		yyy	xxx
M  ddd6		yyy
 M ddd7		yyy	xxx
   eee8		xxx
   eee9		xxx
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
M  aaa0		yyy
   aaa1		xxx
M  bbb2		yyy
 M bbb3		yyy	xxx
   ccc4		xxx
 M ccc5		yyy	xxx
M  ddd6		yyy
 M ddd7		yyy	xxx
   eee8		xxx
   eee9		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
