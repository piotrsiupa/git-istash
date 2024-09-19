. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_KEEP_INDEX

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
printf 'ddd\n' >ddd
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS -u --message 'name of the new stash'
if ! IS_KEEP_INDEX_ON
then
	assert_files_H '
	!! ignored	ignored
	'
else
	assert_files_H '
	A  aaa			aaa
	!! ignored	ignored
	'
fi
assert_stash_H 0 'name of the new stash' '
AM aaa		bbb	aaa
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
AM aaa		bbb	aaa
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
