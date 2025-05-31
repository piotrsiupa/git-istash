# WARNING: This file has a bunch of weird characters in it. (On purpose; they are needed for the test.)
# This also include carriage return characters being at ends of some lines but not others.
# Make sure to use a text editor that will not mangle this.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'This test requires a file system without limitations for file names.'
fi

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

__test_section__ 'Prepare repository'
printf 'xxx\n' >'%^$#&#@'
printf 'xxx\n' >'
'
printf 'xxx\n' >'aaa
bbb'
printf 'xxx\n' >'ccc
ddd'
printf 'xxx\n' >'eee'
printf 'xxx\n' >'eee fff'
printf 'xxx\n' >'fff'
printf 'xxx\n' >'ggg'
printf 'xxx\n' >'"ggg"'
printf 'xxx\n' >'""ggg""'
printf 'xxx\n' >'xXxX*&Xx'
printf 'xxx\n' >'?*?*?*'
printf 'xxx\n' >'^&@*#'
printf 'xxx\n' >'oo'
printf 'xxx\n' >'o%so'
printf 'xxx\n' >'pp'
printf 'xxx\n' >'p%sp'
printf 'xxx\n' >'r	r'
printf 'xxx\n' >'r\tr'
printf 'xxx\n' >'q	q'
printf 'xxx\n' >'q\tq'
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
printf 'yyy\n' >'eee'
printf 'yyy\n' >'eee fff'
printf 'yyy\n' >'fff'
printf 'yyy\n' >'ggg'
printf 'yyy\n' >'"ggg"'
printf 'yyy\n' >'""ggg""'
printf 'yyy\n' >'xXxX*&Xx'
printf 'yyy\n' >'?*?*?*'
printf 'yyy\n' >'^&@*#'
printf 'yyy\n' >'?'
printf 'yyy\n' >'oo'
printf 'yyy\n' >'o%so'
printf 'yyy\n' >'pp'
printf 'yyy\n' >'p%sp'
printf 'yyy\n' >'r	r'
printf 'yyy\n' >'r\tr'
printf 'yyy\n' >'q	q'
printf 'yyy\n' >'q\tq'
git add '%^$#&#@' 'aaa
bbb' 'ggg' '"ggg"' '""ggg""' '^&@*#'
printf 'zzz\n' >'ggg'
printf 'zzz\n' >'"ggg"'
printf 'zzz\n' >'""ggg""'
if ! IS_PATHSPEC_NULL_SEP
then
	printf '*&#?\n"c\\143c\r\nd\\144d"\r\n*\\?*\neee fff\r\n\\"ggg\\"\n"o\\07%%so"\n"p\\7%%sp"\n"r\\tr"\nq\\tq' >.git/pathspec_for_test
else
	printf '*&#?\0ccc\r\nddd\0*\\?*\0eee fff\0"ggg"\0o\007%%so\0p\007%%sp\0r\tr\0q\\tq' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push '*&#?' $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS 'ccc
ddd' -m 'a fine stash' $EOI '*\?*' 'eee fff' '"ggg"' 'o%so' 'p%sp' 'r	r' 'q\tq'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'a fine stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'a fine stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	   %%^$#&#@	xxx
	 M \n		yyy	xxx
	M  aaa\nbbb	yyy
	   ccc\r\nddd	xxx
	 M eee		yyy	xxx
	   eee\040fff	xxx
	 M fff		yyy	xxx
	MM ggg		zzz	yyy
	   "ggg"	xxx
	MM ""ggg""	zzz	yyy
	 M xXxX*&Xx	yyy	xxx
	   ?*?*?*	xxx
	M  ^&@*#	yyy
	 M o\007o	yyy	xxx
	   o\007%%so	xxx
	 M p\007p	yyy	xxx
	   p\007%%sp	xxx
	   r\tr		xxx
	 M r\\tr	yyy	xxx
	 M q\tq		yyy	xxx
	   q\\tq	xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	M  %%^$#&#@	yyy
	 M \n		yyy	xxx
	M  aaa\nbbb	yyy
	   ccc\r\nddd	xxx
	 M eee		yyy	xxx
	   eee\040fff	xxx
	 M fff		yyy	xxx
	MM ggg		zzz	yyy
	M  "ggg"	yyy
	MM ""ggg""	zzz	yyy
	 M xXxX*&Xx	yyy	xxx
	   ?*?*?*	xxx
	M  ^&@*#	yyy
	 M o\007o	yyy	xxx
	   o\007%%so	xxx
	 M p\007p	yyy	xxx
	   p\007%%sp	xxx
	   r\tr		xxx
	 M r\\tr	yyy	xxx
	 M q\tq		yyy	xxx
	   q\\tq	xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_HT 0 'a fine stash' '
M  %%^$#&#@	yyy
   \n		xxx
   aaa\nbbb	xxx
 M ccc\r\nddd	yyy	xxx
   eee		xxx
 M eee\040fff	yyy	xxx
   fff		xxx
   ggg		xxx
MM "ggg"	zzz	yyy
   ""ggg""	xxx
   xXxX*&Xx	xxx
 M ?*?*?*	yyy	xxx
   ^&@*#	xxx
   o\007o	xxx
 M o\007%%so	yyy	xxx
   p\007p	xxx
 M p\007%%sp	yyy	xxx
 M r\tr		yyy	xxx
   r\\tr	xxx
   q\tq		xxx
 M q\\tq	yyy	xxx
?? ?		yyy
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

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
M  %%^$#&#@	yyy
   \n		xxx
   aaa\nbbb	xxx
 M ccc\r\nddd	yyy	xxx
   eee		xxx
 M eee\040fff	yyy	xxx
   fff		xxx
   ggg		xxx
MM "ggg"	zzz	yyy
   ""ggg""	xxx
   xXxX*&Xx	xxx
 M ?*?*?*	yyy	xxx
   ^&@*#	xxx
   o\007o	xxx
 M o\007%%so	yyy	xxx
   p\007p	xxx
 M p\007%%sp	yyy	xxx
 M r\tr		yyy	xxx
   r\\tr	xxx
   q\tq		xxx
 M q\\tq	yyy	xxx
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
assert_branch_metadata_HT
assert_dotgit_contents
