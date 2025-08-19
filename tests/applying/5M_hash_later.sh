. "$commons_path" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Create earlier stash'
printf 'aaa\n' >aaa
git stash push -u -m 'earlier stash entry'
git stash drop
git reset --hard

__test_section__ 'Create later stash'
printf 'bbb\n' >bbb
git stash push -u -m 'later stash entry'
later_stash_hash="$(git rev-parse stash)"
git stash drop
git reset --hard

assert_stash_count 0

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
if IS_APPLY
then
	assert_exit_code 0 git istash apply "$later_stash_hash"
	assert_files_HT '
	?? bbb		bbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_exit_code 1 git istash pop "$later_stash_hash"
	assert_files_HT '
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_count 0
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
