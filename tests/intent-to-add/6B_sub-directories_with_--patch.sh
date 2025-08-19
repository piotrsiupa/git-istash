. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

# We don't need those in this test.
rm ignored0 ignored1

# Some tracked files to make it harder on the algorithms creating the commit for untracked ones.
__test_section__ 'Prepare repository'
mkdir -p 'a/0' 'a/1' 'b/0' 'b/1'
printf 'xxx\nxxx\n' >'a/0/i'
printf 'xxx\nxxx\n' >'a/0/j'
printf 'xxx\nxxx\n' >'a/0/k'
printf 'xxx\nxxx\n' >'a/1/i'
printf 'xxx\nxxx\n' >'a/1/j'
printf 'xxx\nxxx\n' >'a/1/k'
printf 'xxx\nxxx\n' >'b/0/i'
printf 'xxx\nxxx\n' >'b/0/j'
printf 'xxx\nxxx\n' >'b/0/k'
printf 'xxx\nxxx\n' >'b/1/i'
printf 'xxx\nxxx\n' >'b/1/j'
printf 'xxx\nxxx\n' >'b/1/k'
git add .
git commit -m 'Added some files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'yyy\nxxx\nxxx\nyyy\n' >'a/0/i'
rm 'a/0/k'
printf 'yyy\nxxx\nxxx\nyyy\n' >'a/0/l'
git add 'a/0'
printf 'zzz\nxxx\nxxx\nzzz\n' >'a/1/i'
rm 'a/1/k'
printf 'yyy\nxxx\nxxx\nyyy\n' >'a/1/l'
git add -N 'a/1/l'
printf 'yyy\nxxx\nxxx\nyyy\n' >'b/0/i'
printf 'yyy\nxxx\nxxx\nyyy\n' >'b/0/k'
printf 'yyy\nxxx\nxxx\nyyy\n' >'b/0/l'
git add 'b/0'
printf 'zzz\nxxx\nxxx\nzzz\n' >'b/0/i'
rm 'b/0/k'
printf 'zzz\nxxx\nxxx\nzzz\n' >'b/0/l'
printf 's y n y y s n y n s y n ' | tr ' ' '\n' >.git/answers_for_patch
cd 'b'
#shellcheck disable=SC2086
new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS --patch <../.git/answers_for_patch)"
cd -
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	M  a/0/i	yyy\nxxx\nxxx\nyyy
	   a/0/j	xxx\nxxx
	D  a/0/k
	A  a/0/l	yyy\nxxx\nxxx\nyyy
	 M a/1/i	zzz\nxxx\nxxx\nzzz	xxx\nxxx
	   a/1/j	xxx\nxxx
	 D a/1/k	xxx\nxxx
	 A a/1/l	yyy\nxxx\nxxx\nyyy
	MM b/0/i	zzz\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
	   b/0/j	xxx\nxxx
	MD b/0/k	yyy\nxxx\nxxx\nyyy
	AM b/0/l	zzz\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
	   b/1/i	xxx\nxxx
	   b/1/j	xxx\nxxx
	   b/1/k	xxx\nxxx
	' '
	   a/0/i	xxx\nxxx
	   a/0/j	xxx\nxxx
	   a/0/k	xxx\nxxx
	 M a/1/i	xxx\nxxx\nzzz		xxx\nxxx
	   a/1/j	xxx\nxxx
	   a/1/k	xxx\nxxx
	 M b/0/i	zzz\nxxx\nxxx		xxx\nxxx
	   b/0/j	xxx\nxxx
	 D b/0/k	xxx\nxxx
	 A b/0/l	yyy\nxxx\nxxx\nzzz
	   b/1/i	xxx\nxxx
	   b/1/j	xxx\nxxx
	   b/1/k	xxx\nxxx
	'
else
	assert_files_HTCO '
	M  a/0/i	yyy\nxxx\nxxx\nyyy
	   a/0/j	xxx\nxxx
	D  a/0/k
	A  a/0/l	yyy\nxxx\nxxx\nyyy
	 M a/1/i	zzz\nxxx\nxxx\nzzz	xxx\nxxx
	   a/1/j	xxx\nxxx
	 D a/1/k	xxx\nxxx
	 A a/1/l	yyy\nxxx\nxxx\nyyy
	MM b/0/i	zzz\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
	   b/0/j	xxx\nxxx
	MD b/0/k	yyy\nxxx\nxxx\nyyy
	AM b/0/l	zzz\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
	   b/1/i	xxx\nxxx
	   b/1/j	xxx\nxxx
	   b/1/k	xxx\nxxx
	' '
	M  a/0/i	yyy\nxxx\nxxx\nyyy
	   a/0/j	xxx\nxxx
	D  a/0/k
	A  a/0/l	yyy\nxxx\nxxx\nyyy
	 M a/1/i	xxx\nxxx\nzzz		xxx\nxxx
	   a/1/j	xxx\nxxx
	   a/1/k	xxx\nxxx
	MM b/0/i	zzz\nxxx\nxxx\nyyy	yyy\nxxx\nxxx\nyyy
	   b/0/j	xxx\nxxx
	MD b/0/k	yyy\nxxx\nxxx\nyyy
	AM b/0/l	yyy\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
	   b/1/i	xxx\nxxx
	   b/1/j	xxx\nxxx
	   b/1/k	xxx\nxxx
	'
fi
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 '' '
M  a/0/i	yyy\nxxx\nxxx\nyyy
   a/0/j	xxx\nxxx
D  a/0/k
A  a/0/l	yyy\nxxx\nxxx\nyyy
 M a/1/i	zzz\nxxx\nxxx		xxx\nxxx
   a/1/j	xxx\nxxx
 D a/1/k	xxx\nxxx
 A a/1/l	yyy\nxxx\nxxx\nyyy
MM b/0/i	yyy\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
   b/0/j	xxx\nxxx
M  b/0/k	yyy\nxxx\nxxx\nyyy
AM b/0/l	zzz\nxxx\nxxx\nyyy	yyy\nxxx\nxxx\nyyy
   b/1/i	xxx\nxxx
   b/1/j	xxx\nxxx
   b/1/k	xxx\nxxx
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
assert_exit_code 0 git istash pop
assert_files '
M  a/0/i	yyy\nxxx\nxxx\nyyy
   a/0/j	xxx\nxxx
D  a/0/k
A  a/0/l	yyy\nxxx\nxxx\nyyy
 M a/1/i	zzz\nxxx\nxxx		xxx\nxxx
   a/1/j	xxx\nxxx
 D a/1/k	xxx\nxxx
 A a/1/l	yyy\nxxx\nxxx\nyyy
MM b/0/i	yyy\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
   b/0/j	xxx\nxxx
M  b/0/k	yyy\nxxx\nxxx\nyyy
AM b/0/l	zzz\nxxx\nxxx\nyyy	yyy\nxxx\nxxx\nyyy
   b/1/i	xxx\nxxx
   b/1/j	xxx\nxxx
   b/1/k	xxx\nxxx
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
