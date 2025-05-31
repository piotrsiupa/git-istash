. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
assert_files '
   aaa		aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
correct_head_hash="$(get_head_hash_HT)"
printf 'bbb\n' >aaa
if ! IS_HEAD_ORPHAN
then
	assert_exit_code 0 git stash push
	assert_files_HT '
	   aaa		aaa
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
	assert_stash_HT 0 '' '
	 M aaa		bbb	aaa
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
else
	if git stash push --message 'new name'
	then
		# This doesn't work in normal `git stash`
		exit 1
	fi
fi
