. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL
PARAMETRIZE_UNTRACKED
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

# We don't need those in this test.
rm ignored0 ignored1

# Some tracked files to make it harder on the algorithms creating the commit for untracked ones.
__test_section__ 'Prepare repository'
mkdir -p 'a/0' 'a/1' 'b/0' 'b/1'
echo xxx >'a/0/i'
echo xxx >'a/0/j'
echo xxx >'a/0/k'
echo xxx >'a/1/i'
echo xxx >'a/1/j'
echo xxx >'a/1/k'
echo xxx >'b/0/i'
echo xxx >'b/0/j'
echo xxx >'b/0/k'
echo xxx >'b/1/i'
echo xxx >'b/1/j'
echo xxx >'b/1/k'
git add .
git commit -m 'Added some files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
echo yyy >'a/0/i'
rm 'a/0/k'
git add 'a/0'
echo zzz >'a/1/i'
rm 'a/1/k'
echo yyy >'b/0/i'
echo yyy >'b/0/k'
git add 'b/0'
echo zzz >'b/0/i'
rm 'b/0/k'
echo yyy >'b/1/k'
git add 'b/1'
echo zzz >'b/1/i'
#shellcheck disable=SC2086
cd 'a'
printf '0 1/k ../b/0 ../b/1/i ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $EOI '0' '1/k' '../b/0' '../b/1/i'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <../.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file ../.git/pathspec_for_test
fi
cd -
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	   a/0/i	xxx
	   a/0/j	xxx
	   a/0/k	xxx
	 M a/1/i	zzz	xxx
	   a/1/j	xxx
	   a/1/k	xxx
	   b/0/i	xxx
	   b/0/j	xxx
	   b/0/k	xxx
	   b/1/i	xxx
	   b/1/j	xxx
	M  b/1/k	yyy
	'
else
	assert_files_HT '
	M  a/0/i	yyy
	   a/0/j	xxx
	D  a/0/k
	 M a/1/i	zzz	xxx
	   a/1/j	xxx
	   a/1/k	xxx
	M  b/0/i	yyy
	   b/0/j	xxx
	M  b/0/k	yyy
	   b/1/i	xxx
	   b/1/j	xxx
	M  b/1/k	yyy
	'
fi
assert_stash_HT 0 '' '
M  a/0/i	yyy
   a/0/j	xxx
D  a/0/k
   a/1/i	xxx
   a/1/j	xxx
 D a/1/k	xxx
MM b/0/i	zzz	yyy
   b/0/j	xxx
MD b/0/k	yyy
 M b/1/i	zzz	xxx
   b/1/j	xxx
   b/1/k	xxx
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
M  a/0/i	yyy
   a/0/j	xxx
D  a/0/k
   a/1/i	xxx
   a/1/j	xxx
 D a/1/k	xxx
MM b/0/i	zzz	yyy
   b/0/j	xxx
MD b/0/k	yyy
 M b/1/i	zzz	xxx
   b/1/j	xxx
   b/1/k	xxx
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
