. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
assert_files '
   aaa		aaa
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_rebase n

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
correct_head_hash="$(get_head_hash_H)"
printf 'ddd\n' >ddd
if ! IS_HEAD_ORPHAN
then
	assert_exit_code 0 git stash push -u -m 'name'
	assert_files_H '
	   aaa		aaa
	!! ignored	ignored
	'
	assert_stash_H 0 'name' '
	   aaa		aaa
	?? ddd		ddd
	'
	assert_stash_base_H 0 'HEAD'
	assert_stash_count 1
	assert_log_length_H 2
	assert_branch_count 1
	assert_head_hash_H "$correct_head_hash"
	assert_head_name_H
	assert_rebase n
else
	if git stash push -u --message 'name'
	then
		# This doesn't work in normal `git stash`
		exit 1
	fi
fi
