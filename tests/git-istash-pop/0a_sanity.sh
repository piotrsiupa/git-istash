. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

if ! IS_HEAD_ORPHAN
then
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
	assert_data_files 'none'
	assert_rebase n
fi

printf 'bbb\n' >aaa
git add aaa
git stash push
assert_files_H '
   aaa		aaa
!! ignored	ignored
' '
!! ignored	ignored
'
assert_stash_count 1
if ! IS_HEAD_ORPHAN
then
	assert_log_length 2
else
	assert_log_length 1
fi
assert_branch_count 1
assert_data_files 'none'
assert_rebase n

SWITCH_HEAD_TYPE

correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git stash pop --index
assert_files_H '
M  aaa		bbb
!! ignored	ignored
' '
A  aaa		bbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
