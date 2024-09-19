. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP

__test_section__ 'Create earlier stash'
printf 'aaa\n' >aaa
git stash push -u -m 'earlier stash entry'
earlier_stash_hash="$(git rev-parse stash)"
git stash drop
git reset --hard

__test_section__ 'Create later stash'
printf 'bbb\n' >bbb
git stash push -u -m 'later stash entry'
git stash drop
git reset --hard

assert_stash_count 0

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
if IS_APPLY
then
	assert_exit_code 0 git istash apply "$earlier_stash_hash"
	assert_files_H '
	?? aaa		aaa
	!! ignored	ignored
	'
else
	assert_exit_code 1 git istash pop "$earlier_stash_hash"
	assert_files_H '
	!! ignored	ignored
	'
fi
assert_stash_count 0
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
