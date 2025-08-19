. "$commons_path" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'bbb\n' >aaa
git add aaa
#shellcheck disable=SC2086
new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS -m 'new stash' $ALL_FLAGS $UNTRACKED_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS)"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	A  aaa		bbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	A  aaa		bbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	A  aaa		bbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 'new stash' '
A  aaa		bbb
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
A  aaa		bbb
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
