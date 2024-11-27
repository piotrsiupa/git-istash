. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP

__test_section__ 'Prepare repository'
if ! IS_HEAD_ORPHAN
then
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
	assert_data_files 'none'
	assert_rebase n
fi

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
git stash push
assert_files_H '
   aaa		aaa
!! ignored0	ignored0
!! ignored1	ignored1
' '
!! ignored0	ignored0
!! ignored1	ignored1
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
assert_branch_metadata_H

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git stash "$OPERATION" --index
assert_files_H '
M  aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
A  aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_O 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_H
