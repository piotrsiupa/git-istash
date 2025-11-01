. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE 'ARGS' 'FILE' 'NULL-FILE'
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

# We don't need those in this test.
rm ignored0 ignored1

# Some tracked files to make it harder on the algorithms creating the commit for untracked ones.
__test_section__ 'Prepare repository'
mkdir -p 'a/0' 'a/1' 'b/0' 'b/1'
printf 'xxx\n' >'a/0/i'
printf 'xxx\n' >'a/0/j'
printf 'xxx\n' >'a/0/k'
printf 'xxx\n' >'a/1/i'
printf 'xxx\n' >'a/1/j'
printf 'xxx\n' >'a/1/k'
printf 'xxx\n' >'b/0/i'
printf 'xxx\n' >'b/0/j'
printf 'xxx\n' >'b/0/k'
printf 'xxx\n' >'b/1/i'
printf 'xxx\n' >'b/1/j'
printf 'xxx\n' >'b/1/k'
git add .
git commit -m 'Added some files'

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'yyy\n' >'a/0/i'
rm 'a/0/k'
git add 'a/0'
printf 'zzz\n' >'a/1/i'
rm 'a/1/k'
printf 'yyy\n' >'b/0/i'
printf 'yyy\n' >'b/0/k'
git add 'b/0'
printf 'zzz\n' >'b/0/i'
rm 'b/0/k'
printf 'yyy\n' >'b/1/k'
git add 'b/1'
printf 'zzz\n' >'b/1/i'
#shellcheck disable=SC2086
cd 'a'
printf 'y y n n ' | tr ' ' '\n' >../.git/answers_for_patch
printf '0 1/k ../b/0 ../b/1/i ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS --patch $EOI '0' '1/k' '../b/0' '../b/1/i' <../.git/answers_for_patch
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $PATHSPEC_NULL_FLAGS --patch --pathspec-from-file ../.git/pathspec_for_test -- <../.git/answers_for_patch
fi
cd -
assert_outputs__create__success '1,1,1,1' ''
new_stash_sha_CO="$stdout"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	M  a/0/i	yyy
	   a/0/j	xxx
	D  a/0/k
	 M a/1/i	zzz	xxx
	   a/1/j	xxx
	 D a/1/k	xxx
	MM b/0/i	zzz	yyy
	   b/0/j	xxx
	MD b/0/k	yyy
	 M b/1/i	zzz	xxx
	   b/1/j	xxx
	M  b/1/k	yyy
	' '
	   a/0/i	xxx
	   a/0/j	xxx
	   a/0/k	xxx
	 M a/1/i	zzz	xxx
	   a/1/j	xxx
	   a/1/k	xxx
	   b/0/i	xxx
	   b/0/j	xxx
	 D b/0/k	xxx
	 M b/1/i	zzz	xxx
	   b/1/j	xxx
	M  b/1/k	yyy
	'
else
	assert_files_HTCO '
	M  a/0/i	yyy
	   a/0/j	xxx
	D  a/0/k
	 M a/1/i	zzz	xxx
	   a/1/j	xxx
	 D a/1/k	xxx
	MM b/0/i	zzz	yyy
	   b/0/j	xxx
	MD b/0/k	yyy
	 M b/1/i	zzz	xxx
	   b/1/j	xxx
	M  b/1/k	yyy
	' '
	M  a/0/i	yyy
	   a/0/j	xxx
	D  a/0/k
	 M a/1/i	zzz	xxx
	   a/1/j	xxx
	   a/1/k	xxx
	M  b/0/i	yyy
	   b/0/j	xxx
	MD b/0/k	yyy
	 M b/1/i	zzz	xxx
	   b/1/j	xxx
	M  b/1/k	yyy
	'
fi
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
M  a/0/i	yyy
   a/0/j	xxx
D  a/0/k
   a/1/i	xxx
   a/1/j	xxx
 D a/1/k	xxx
MM b/0/i	zzz	yyy
   b/0/j	xxx
M  b/0/k	yyy
   b/1/i	xxx
   b/1/j	xxx
   b/1/k	xxx
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
M  a/0/i	yyy
   a/0/j	xxx
D  a/0/k
   a/1/i	xxx
   a/1/j	xxx
 D a/1/k	xxx
MM b/0/i	zzz	yyy
   b/0/j	xxx
M  b/0/k	yyy
   b/1/i	xxx
   b/1/j	xxx
   b/1/k	xxx
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
