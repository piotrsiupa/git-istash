. "$commons_path" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

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
	assert_dotgit_contents
fi

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
git stash push
assert_files_HT '
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
assert_branch_metadata_HT
assert_dotgit_contents

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
assert_exit_code 0 git stash "$APPLY_OPERATION" --index
assert_files_HT '
M  aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
A  aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
