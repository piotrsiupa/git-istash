. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL
PARAMETRIZE_UNTRACKED
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

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

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'yyy\n' >'a/0/i'
rm 'a/0/k'
printf 'yyy\n' >'a/0/l'
git add 'a/0'
printf 'zzz\n' >'a/1/i'
rm 'a/1/k'
printf 'yyy\n' >'b/0/i'
printf 'yyy\n' >'b/0/k'
printf 'yyy\n' >'b/0/l'
git add 'b/0'
printf 'zzz\n' >'b/0/i'
rm 'b/0/k'
printf 'zzz\n' >'b/0/l'
cd 'a'
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS
cd -
if ! IS_KEEP_INDEX_ON
then
	assert_files_H '
	   a/0/i	xxx
	   a/0/j	xxx
	   a/0/k	xxx
	   a/1/i	xxx
	   a/1/j	xxx
	   a/1/k	xxx
	   b/0/i	xxx
	   b/0/j	xxx
	   b/0/k	xxx
	   b/1/i	xxx
	   b/1/j	xxx
	   b/1/k	xxx
	'
else
	assert_files_H '
	M  a/0/i	yyy
	   a/0/j	xxx
	D  a/0/k
	A  a/0/l	yyy
	   a/1/i	xxx
	   a/1/j	xxx
	   a/1/k	xxx
	M  b/0/i	yyy
	   b/0/j	xxx
	M  b/0/k	yyy
	A  b/0/l	yyy
	   b/1/i	xxx
	   b/1/j	xxx
	   b/1/k	xxx
	'
fi
assert_stash_H 0 '' '
M  a/0/i	yyy
   a/0/j	xxx
D  a/0/k
A  a/0/l	yyy
 M a/1/i	zzz	xxx
   a/1/j	xxx
 D a/1/k	xxx
MM b/0/i	zzz	yyy
   b/0/j	xxx
MD b/0/k	yyy
AM b/0/l	zzz	yyy
   b/1/i	xxx
   b/1/j	xxx
   b/1/k	xxx
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
M  a/0/i	yyy
   a/0/j	xxx
D  a/0/k
A  a/0/l	yyy
 M a/1/i	zzz	xxx
   a/1/j	xxx
 D a/1/k	xxx
MM b/0/i	zzz	yyy
   b/0/j	xxx
MD b/0/k	yyy
AM b/0/l	zzz	yyy
   b/1/i	xxx
   b/1/j	xxx
   b/1/k	xxx
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
