. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION 'push'

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
printf 'xxx\n' >aaa
git stash push -m 'pre-existing stash 0'
printf 'yyy\n' >aaa
git add aaa
printf 'zzz\n' >aaa
git stash push -m 'pre-existing stash 1'
assert_files '
   aaa		aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 2
assert_log_length 2
assert_branch_count 1
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
correct_pre_stash_hash_0="$(git rev-parse 'stash@{1}')"
correct_pre_stash_hash_1="$(git rev-parse 'stash@{0}')"
correct_head_hash="$(get_head_hash_HT)"
printf 'bbb\n' >aaa
if ! IS_HEAD_ORPHAN
then
	assert_exit_code 0 git stash "$CREATE_OPERATION" -m 'some name'
	assert_files_HTCO '' '
	   aaa		aaa
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
	assert_stash_HTCO 0 'some name' '
	 M aaa		bbb	aaa
	'
	assert_stash_base_HT 0 'HEAD'
	assert_stash_count 3
	assert_log_length_HT 2
	assert_branch_count 1
	assert_head_hash_HT "$correct_head_hash"
	assert_stash_hash 2 "$correct_pre_stash_hash_0"
	assert_stash_hash 1 "$correct_pre_stash_hash_1"
	assert_head_name_HT
	assert_rebase n
	assert_branch_metadata_HT
	assert_dotgit_contents
else
	if git stash "$CREATE_OPERATION"
	then
		# This doesn't work in normal `git stash`
		exit 1
	fi
fi
