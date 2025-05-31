. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES'
PARAMETRIZE_KEEP_INDEX 'DEFAULT' 'YES'
PARAMETRIZE_STAGED 'YES' 'NO'
PARAMETRIZE_UNSTAGED 'YES' 'NO'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_EXCLUDE

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
printf 'zzz\n' >aaa0
printf 'zzz\n' >ddd9
printf 'zzz\n' >eee12
printf '%s' ":$EXCLUDE_PATTERN" | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'ms. stash' --allow-empty ":$EXCLUDE_PATTERN"
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'ms. stash' --allow-empty $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'ms. stash' --allow-empty $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
assert_files_HT '
MM aaa0		zzz	yyy
 M aaa1		yyy	xxx
?? aaa2		yyy
M  bbb3		yyy
 M bbb4		yyy	xxx
?? bbb5		yyy
M  ccc6		yyy
 M ccc7		yyy	xxx
?? ccc8		yyy
MM ddd9		zzz	yyy
 M ddd10	yyy	xxx
?? ddd11	yyy
MM eee12	zzz	yyy
 M eee13	yyy	xxx
?? eee14	yyy
!! ignored1	ignored1
!! ignored0	ignored0
'
assert_stash_HT 0 'ms. stash' '
   aaa0		xxx
   aaa1		xxx
   bbb3		xxx
   bbb4		xxx
   ccc6		xxx
   ccc7		xxx
   ddd9		xxx
   ddd10	xxx
   eee12	xxx
   eee13	xxx
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
   aaa0		xxx
   aaa1		xxx
?? aaa2		yyy
   bbb3		xxx
   bbb4		xxx
?? bbb5		yyy
   ccc6		xxx
   ccc7		xxx
?? ccc8		yyy
   ddd9		xxx
   ddd10	xxx
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
assert_branch_metadata_HT
assert_dotgit_contents
