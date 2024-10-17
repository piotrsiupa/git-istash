. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

known_failure 'There is a bug in Git which makes it disregard pathspec for files in index.'
if IS_UNTRACKED_ON
then
	known_failure 'The flag "-u" in "git stash" seems to override "-a" while I would like it to be additive.'
fi
if IS_KEEP_INDEX_ON
then
	known_failure 'It looks like in the standard "git stash" options "-k" and "-u" and alergic to each other.'
fi
if IS_OPTIONS_INDICATOR_ON
then
	known_failure 'Standard implementation of "git stash" does not adhere to the POSIX utility convention.'
fi

__test_section__ 'Prepare repository'
printf 'xxx\n' >aaa0
printf 'xxx\n' >aaa1
printf 'xxx\n' >bbb3
printf 'xxx\n' >bbb4
printf 'xxx\n' >ccc6
printf 'xxx\n' >ccc7
printf 'xxx\n' >ddd9
printf 'xxx\n' >ddd10
printf 'xxx\n' >eee12
printf 'xxx\n' >eee13
git add .
git commit -m 'Added a bunch of files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'yyy\n' >aaa0
printf 'yyy\n' >aaa1
printf 'yyy\n' >aaa2
printf 'yyy\n' >bbb3
printf 'yyy\n' >bbb4
printf 'yyy\n' >bbb5
printf 'yyy\n' >ccc6
printf 'yyy\n' >ccc7
printf 'yyy\n' >ccc8
printf 'yyy\n' >ddd9
printf 'yyy\n' >ddd10
printf 'yyy\n' >ddd11
printf 'yyy\n' >eee12
printf 'yyy\n' >eee13
printf 'yyy\n' >eee14
git add aaa0 bbb3 ccc6 ddd9 eee12

if ! IS_PATHSPEC_NULL_SEP
then
	printf 'aaa0 bbb? *7 c?c8 *ore?0 ./?dd* ' | tr ' ' '\n' >.git/pathspec_for_test
else
	printf 'aaa0 bbb? *7 c?c8 *ore?0 ./?dd* ' | tr ' ' '\0' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	assert_exit_code 0 git istash push 'aaa0' $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS 'bbb?' -m 'new stash' $EOI '*7' 'c?c8' '*ore?0' './?dd*'
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
	?? aaa2		yyy
	   bbb3		xxx
	   bbb4		xxx
	M  ccc6		yyy
	   ccc7		xxx
	   ddd9		xxx
	   ddd10	xxx
	M  eee12	yyy
	 M eee13	yyy	xxx
	?? eee14	yyy
	!! ignored1	ignored1
	'
else
	assert_files_H '
	M  aaa0		yyy
	 M aaa1		yyy	xxx
	?? aaa2		yyy
	M  bbb3		yyy
	   bbb4		xxx
	M  ccc6		yyy
	   ccc7		xxx
	M  ddd9		yyy
	   ddd10	xxx
	M  eee12	yyy
	 M eee13	yyy	xxx
	?? eee14	yyy
	!! ignored1	ignored1
	'
fi
assert_stash_H 0 'new stash' '
M  aaa0		yyy
   aaa1		xxx
M  bbb3		yyy
 M bbb4		yyy	xxx
?? bbb5		yyy
   ccc6		xxx
 M ccc7		yyy	xxx
?? ccc8		yyy
M  ddd9		yyy
 M ddd10	yyy	xxx
?? ddd11	yyy
   eee12	xxx
   eee13	xxx
!! ignored0	ignored0
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
?? aaa2		yyy
M  bbb3		yyy
 M bbb4		yyy	xxx
?? bbb5		yyy
   ccc6		xxx
 M ccc7		yyy	xxx
?? ccc8		yyy
M  ddd9		yyy
 M ddd10	yyy	xxx
?? ddd11	yyy
   eee12	xxx
   eee13	xxx
?? eee14	yyy
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
