. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

known_failure 'There is a bug in Git which makes it disregard pathspec for files in index.'
if IS_OPTIONS_INDICATOR_ON
then
	known_failure 'Standard implementation of "git stash" does not adhere to the POSIX utility convention.'
fi

__test_section__ 'Prepare repository'
printf 'xxx\n' >'%^$#&#@'
printf 'xxx\n' >'
'
printf 'xxx\n' >'aaa
bbb'
printf 'xxx\n' >'ccc
ddd'
printf 'xxx\n' >'xXxX*&Xx'
printf 'xxx\n' >'?*?*?*'
printf 'xxx\n' >'^&@*#'
git add .
git commit -m 'Added a bunch of files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'yyy\n' >'%^$#&#@'
printf 'yyy\n' >'
'
printf 'yyy\n' >'aaa
bbb'
printf 'yyy\n' >'ccc
ddd'
printf 'yyy\n' >'xXxX*&Xx'
printf 'yyy\n' >'?*?*?*'
printf 'yyy\n' >'^&@*#'
printf 'yyy\n' >'?'
git add '%^$#&#@' 'aaa
bbb' '^&@*#'

if ! IS_PATHSPEC_NULL_SEP
then
	printf '*&#?\n"ccc\\nddd"\n*\\?*\n' >.git/pathspec_for_test
else
	printf '*&#?\0ccc\nddd\0*\\?*' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push '*&#?' $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS 'ccc
ddd' -m 'a fine stash' $EOI '*\?*'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'a fine stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'a fine stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
if ! IS_KEEP_INDEX_ON
then
	assert_files_H '
	   %^$#&#@	xxx
	 M \n		yyy	xxx
	M  aaa\nbbb	yyy
	   ccc\nddd	xxx
	 M xXxX*&Xx	yyy	xxx
	   ?*?*?*	xxx
	M  ^&@*#	yyy
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_H '
	M  %^$#&#@	yyy
	 M \n		yyy	xxx
	M  aaa\nbbb	yyy
	   ccc\nddd	xxx
	 M xXxX*&Xx	yyy	xxx
	   ?*?*?*	xxx
	M  ^&@*#	yyy
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_H 0 'a fine stash' '
M  %^$#&#@	yyy
   \n		xxx
   aaa\nbbb	xxx
 M ccc\nddd	yyy	xxx
   xXxX*&Xx	xxx
 M ?*?*?*	yyy	xxx
   ^&@*#	xxx
?? ?		yyy
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
M  %^$#&#@	yyy
   \n		xxx
   aaa\nbbb	xxx
 M ccc\nddd	yyy	xxx
   xXxX*&Xx	xxx
 M ?*?*?*	yyy	xxx
   ^&@*#	xxx
?? ?		yyy
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
