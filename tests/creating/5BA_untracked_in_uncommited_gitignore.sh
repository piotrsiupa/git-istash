. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED

__test_section__ 'Prepare repository'
printf 'X' >.gitignore
git add .gitignore
git commit -m 'Added empty ".gitignore"'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
printf 'aaa\n' >.gitignore
git add .gitignore
#shellcheck disable=SC2086
new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $UNTRACKED_FLAGS $ALL_FLAGS -mX)"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	M  .gitignore	aaa
	!! aaa		aaa
	?? bbb		bbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	   .gitignore	X
	?? aaa		aaa
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HTCO '
	M  .gitignore	aaa
	!! aaa		aaa
	?? bbb		bbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	M  .gitignore	aaa
	!! aaa		aaa
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 'X' '
M  .gitignore	aaa
?? bbb		bbb
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 2
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
M  .gitignore	aaa
?? bbb		bbb
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
