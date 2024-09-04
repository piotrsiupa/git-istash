. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

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
!! ignored	ignored
'
assert_stash_count 2
assert_log_length 2
assert_branch_count 1
assert_rebase n

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
correct_pre_stash_hash_0="$(git rev-parse 'stash@{1}')"
correct_pre_stash_hash_1="$(git rev-parse 'stash@{0}')"
correct_head_hash="$(get_head_hash_H)"
printf 'bbb\n' >aaa
if ! IS_HEAD_ORPHAN
then
	assert_exit_code 0 git stash push -m 'some name'
	assert_files_H '
	   aaa		aaa
	!! ignored	ignored
	'
	assert_stash_H 0 'some name' '
	 M aaa		bbb	aaa
	'
	assert_stash_base_H 0 'HEAD'
	assert_stash_count 3
	assert_log_length_H 2
	assert_branch_count 1
	assert_head_hash_H "$correct_head_hash"
	assert_stash_hash 2 "$correct_pre_stash_hash_0"
	assert_stash_hash 1 "$correct_pre_stash_hash_1"
	assert_head_name_H
	assert_rebase n
else
	if git stash push
	then
		# This doesn't work in normal `git stash`
		exit 1
	fi
fi
