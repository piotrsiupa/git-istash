. "$commons_path" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX 'NO'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'xxx\n' >aaa0
printf 'xxx\n' >aaa1
printf 'xxx\n' >bbb2
printf 'xxx\n' >bbb3
printf 'xxx\n' >ccc4
printf 'xxx\n' >ccc5
printf 'xxx\n' >ddd6
printf 'xxx\n' >ddd7
printf 'xxx\n' >eee8
printf 'xxx\n' >eee9
printf 'aaa0 bbb? *5 ./?dd* ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" 'aaa0' $KEEP_INDEX_FLAGS $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS 'bbb?' $ALL_FLAGS -m 'a stash' '*5' './?dd*')"
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'a stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test)"
else
	#shellcheck disable=SC2086
	new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'a stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test)"
fi
assert_files_HTCO '
?? aaa0		xxx
?? aaa1		xxx
?? bbb2		xxx
?? bbb3		xxx
?? ccc4		xxx
?? ccc5		xxx
?? ddd6		xxx
?? ddd7		xxx
?? eee8		xxx
?? eee9		xxx
!! ignored0	ignored0
!! ignored1	ignored1
' '
?? aaa1		xxx
?? ccc4		xxx
?? eee8		xxx
?? eee9		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 'a stash' '
?? aaa0		xxx
?? bbb2		xxx
?? bbb3		xxx
?? ccc5		xxx
?? ddd6		xxx
?? ddd7		xxx
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
?? aaa0		xxx
?? bbb2		xxx
?? bbb3		xxx
?? ccc5		xxx
?? ddd6		xxx
?? ddd7		xxx
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
