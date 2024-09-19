. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_KEEP_INDEX

if IS_KEEP_INDEX_ON
then
	known_failure 'a confirmed bug in "git stash"'
fi

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'ddd\n' >ddd
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS -u --message='stash message'
if ! IS_KEEP_INDEX_ON
then
	assert_files_H '
	!! ignored	ignored
	'
else
	assert_files_H '
	!! ignored	ignored
	'
fi
assert_stash_H 0 'stash message' '
?? ddd		ddd
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
