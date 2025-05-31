. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
printf 'xxx\n' >aaa0
printf 'xxx\n' >aaa1
printf 'xxx\n' >bbb0
printf 'xxx\n' >bbb1
git add .
git commit -m 'Added some files'
printf '*0\n' >.gitignore
git add .gitignore
git commit -m 'Ignored files ending with "0"'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'yyy\n' >aaa0
printf 'yyy\n' >aaa1
git add aaa0 aaa1
printf 'yyy\n' >bbb0
printf 'yyy\n' >bbb1
printf 'yyy\n' >ccc0
printf 'yyy\n' >ccc1
printf 'yyy\n' >ddd0
printf 'yyy\n' >ddd1
git add --force ddd0 ddd1
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS --message 'name'
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	   aaa0		xxx
	   aaa1		xxx
	   bbb0		xxx
	   bbb1		xxx
	!! ccc0		yyy
	   .gitignore	*0
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	M  aaa0		yyy
	M  aaa1		yyy
	   bbb0		xxx
	   bbb1		xxx
	!! ccc0		yyy
	A  ddd0		yyy
	A  ddd1		yyy
	   .gitignore	*0
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_HT 0 'name' '
M  aaa0		yyy
M  aaa1		yyy
 M bbb0		yyy		xxx
 M bbb1		yyy		xxx
?? ccc1		yyy
A  ddd0		yyy
A  ddd1		yyy
   .gitignore	*0
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 3
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
M  aaa0		yyy
M  aaa1		yyy
 M bbb0		yyy		xxx
 M bbb1		yyy		xxx
!! ccc0		yyy
?? ccc1		yyy
A  ddd0		yyy
A  ddd1		yyy
   .gitignore	*0
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
