. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION 'create' 'push'

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

__test_section__ "$CAP_CREATE_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
printf 'bbb\n' >aaa
if ! IS_HEAD_ORPHAN
then
	new_stash_sha_CO="$(assert_exit_code 0 git stash "$CREATE_OPERATION")"
	if [ "$CREATE_OPERATION" = 'push' ]
	then
		new_stash_sha_CO=''
	fi
	assert_files_HTCO '
	 M aaa		bbb	aaa
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	   aaa		aaa
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
	store_stash_CO "$new_stash_sha_CO"
	assert_stash_HTCO 0 '' '
	 M aaa		bbb	aaa
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
else
	if git stash "$CREATE_OPERATION" --message 'new name'
	then
		# This doesn't work in normal `git stash`
		exit 1
	fi
fi
