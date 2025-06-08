. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE 'ARGS' 'FILE' 'NULL-FILE'
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

__test_section__ 'Prepare repository'
printf 'xxx\nxxx\n' >aaa0
printf 'xxx\nxxx\n' >aaa1
printf 'xxx\nxxx\n' >bbb2
printf 'xxx\nxxx\n' >bbb3
printf 'xxx\nxxx\n' >ccc4
printf 'xxx\nxxx\n' >ccc5
printf 'xxx\nxxx\n' >ddd6
printf 'xxx\nxxx\n' >ddd7
printf 'xxx\nxxx\n' >eee8
printf 'xxx\nxxx\n' >eee9
git add .
git commit -m 'Added a bunch of files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'yyy\nxxx\nxxx\nyyy\n' >aaa0
printf 'yyy\nxxx\nxxx\nyyy\n' >aaa1
printf 'yyy\nxxx\nxxx\nyyy\n' >bbb2
printf 'yyy\nxxx\nxxx\nyyy\n' >bbb3
printf 'yyy\nxxx\nxxx\nyyy\n' >ccc4
printf 'yyy\nxxx\nxxx\nyyy\n' >ccc5
printf 'yyy\nxxx\nxxx\nyyy\n' >ddd6
printf 'yyy\nxxx\nxxx\nyyy\n' >eee8
printf 'yyy\nxxx\nxxx\nyyy\n' >eee9
printf 'yyy\nyyy\n' >fff10
printf 'yyy\nyyy\n' >fff11
git add aaa0 bbb2 ccc4 ddd6 eee8
printf 'zzz\nxxx\nxxx\nzzz\n' >ccc4
rm bbb2 ddd7
printf 'y s y n s n y n ' | tr ' ' '\n' >.git/answers_for_patch0
printf 'y n ' | tr ' ' '\n' >.git/answers_for_patch1
printf 'aaa0 bbb? *5 ./?dd* fff1? ' | PREPARE_PATHSPEC_FILE
{
	 cat .git/answers_for_patch0
	 sleep 5  # On Windows a child shell tends to eat all the stdin if it's able to. This prevents it. If it still doesn't work, try to increase the time.
	 cat .git/answers_for_patch1
} \
| if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push 'aaa0' $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS 'bbb?' --patch -m 'a very controlled stash' $EOI '*5' './?dd*' 'fff1?'
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'a very controlled stash' --patch $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	   aaa0		xxx\nxxx
	 M aaa1		yyy\nxxx\nxxx\nyyy	xxx\nxxx
	   bbb2		xxx\nxxx
	 M bbb3		xxx\nxxx\nyyy		xxx\nxxx
	MM ccc4		zzz\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
	 M ccc5		yyy\nxxx\nxxx		xxx\nxxx
	   ddd6		xxx\nxxx
	 D ddd7		xxx\nxxx
	M  eee8		yyy\nxxx\nxxx\nyyy
	 M eee9		yyy\nxxx\nxxx\nyyy	xxx\nxxx
	?? fff11	yyy\nyyy
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	M  aaa0		yyy\nxxx\nxxx\nyyy
	 M aaa1		yyy\nxxx\nxxx\nyyy	xxx\nxxx
	M  bbb2		yyy\nxxx\nxxx\nyyy
	 M bbb3		xxx\nxxx\nyyy		xxx\nxxx
	MM ccc4		zzz\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
	 M ccc5		yyy\nxxx\nxxx		xxx\nxxx
	M  ddd6		yyy\nxxx\nxxx\nyyy
	 D ddd7		xxx\nxxx
	M  eee8		yyy\nxxx\nxxx\nyyy
	 M eee9		yyy\nxxx\nxxx\nyyy	xxx\nxxx
	?? fff11	yyy\nyyy
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_HT 0 'a very controlled stash' '
M  aaa0		yyy\nxxx\nxxx\nyyy
   aaa1		xxx\nxxx
MD bbb2		yyy\nxxx\nxxx\nyyy
 M bbb3		yyy\nxxx\nxxx		xxx\nxxx
   ccc4		xxx\nxxx
 M ccc5		xxx\nxxx\nyyy		xxx\nxxx
M  ddd6		yyy\nxxx\nxxx\nyyy
   ddd7		xxx\nxxx
   eee8		xxx\nxxx
   eee9		xxx\nxxx
?? fff10	yyy\nyyy
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
M  aaa0		yyy\nxxx\nxxx\nyyy
   aaa1		xxx\nxxx
MD bbb2		yyy\nxxx\nxxx\nyyy
 M bbb3		yyy\nxxx\nxxx		xxx\nxxx
   ccc4		xxx\nxxx
 M ccc5		xxx\nxxx\nyyy		xxx\nxxx
M  ddd6		yyy\nxxx\nxxx\nyyy
   ddd7		xxx\nxxx
   eee8		xxx\nxxx
   eee9		xxx\nxxx
?? fff10	yyy\nyyy
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
