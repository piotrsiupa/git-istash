. "$commons_path" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Create earlier stash'
printf 'aaa\n' >aaa
git stash push -u -m 'earlier stash entry'
earlier_stash_hash="$(get_stash_hash)"

__test_section__ 'Create later stash'
printf 'bbb\n' >bbb
git stash push -u -m 'later stash entry'
later_stash_hash="$(get_stash_hash)"

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
assert_exit_code 0 git istash "$APPLY_OPERATION" -- "stash"
assert_files_HT '
?? bbb		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 2
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
if IS_APPLY
then
	assert_stash_hash 1 "$earlier_stash_hash"
	assert_stash_hash 0 "$later_stash_hash"
else
	assert_stash_hash 0 "$earlier_stash_hash"
fi
assert_branch_metadata_HT
assert_dotgit_contents
