. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

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
git rm aaa0 bbb2 ccc4 ddd6 eee8
rm aaa1 bbb3 ccc5 ddd7 eee9
printf 'aaa0 bbb? *5 ./?dd* ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push 'aaa0' $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS 'bbb?' -m 'new stash' $EOI '*5' './?dd*'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	   aaa0		xxx
	 D aaa1		xxx
	   bbb2		xxx
	   bbb3		xxx
	D  ccc4
	   ccc5		xxx
	   ddd6		xxx
	   ddd7		xxx
	D  eee8
	 D eee9		xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	D  aaa0
	 D aaa1		xxx
	D  bbb2
	   bbb3		xxx
	D  ccc4
	   ccc5		xxx
	D  ddd6
	   ddd7		xxx
	D  eee8
	 D eee9		xxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_HT 0 'new stash' '
D  aaa0
   aaa1		xxx
D  bbb2
 D bbb3		xxx
   ccc4		xxx
 D ccc5		xxx
D  ddd6
 D ddd7		xxx
   eee8		xxx
   eee9		xxx
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
D  aaa0
   aaa1		xxx
D  bbb2
 D bbb3		xxx
   ccc4		xxx
 D ccc5		xxx
D  ddd6
 D ddd7		xxx
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
assert_branch_metadata_HT
assert_dotgit_contents
