. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
printf 'aaa1\n' >aaa
printf 'bbb1\n' >bbb
printf 'ccc1\n' >ccc
printf 'ddd1\n' >ddd
git add aaa bbb ccc ddd
git commit -m 'Added aaa, bbb, ccc & ddd'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa2\n' >aaa
printf 'bbb2\n' >bbb
git add aaa bbb
printf 'bbb3\n' >bbb
printf 'ddd3\n' >ddd
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS $ALL_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $UNTRACKED_FLAGS
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	   aaa		aaa1
	   bbb		bbb1
	   ccc		ccc1
	   ddd		ddd1
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	M  aaa		aaa2
	M  bbb		bbb2
	   ccc		ccc1
	   ddd		ddd1
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_HT 0 '' '
M  aaa			aaa2
MM bbb		bbb3	bbb2
   ccc		ccc1
 M ddd		ddd3	ddd1
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
M  aaa			aaa2
MM bbb		bbb3	bbb2
   ccc		ccc1
 M ddd		ddd3	ddd1
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
