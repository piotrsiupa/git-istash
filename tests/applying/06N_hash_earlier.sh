. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Create earlier stash'
printf 'aaa\n' >aaa
git stash push -u -m 'earlier stash entry'
earlier_stash_sha="$(git rev-parse stash)"
git stash drop
git reset --hard

__test_section__ 'Create later stash'
printf 'bbb\n' >bbb
git stash push -u -m 'later stash entry'
git stash drop
git reset --hard

assert_stash_count 0

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
if IS_APPLY
then
	assert_exit_code 0 git istash apply "$earlier_stash_sha"
	assert_outputs__apply__success "$APPLY_OPERATION" 0 "$earlier_stash_sha"
	assert_files_HT '
	?? aaa		aaa
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_exit_code 1 git istash pop "$earlier_stash_sha"
	assert_outputs__apply__non_stash_on_pop
	assert_files_HT '
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_count 0
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
