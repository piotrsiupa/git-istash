. "$commons_path" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES'
PARAMETRIZE_KEEP_INDEX 'YES'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'NO'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
printf 'y n y n ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS --patch $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS -message <.git/answers_for_patch)"
assert_files_HTCO '
?? aaa		aaa
?? bbb		bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
?? bbb		bbb
!! ignored1	ignored1
'
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 'essage' '
?? aaa		aaa
!! ignored0	ignored0
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
?? aaa		aaa
!! ignored0	ignored0
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
