. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX 'NO'
PARAMETRIZE_STAGED 'NO'
PARAMETRIZE_UNSTAGED 'NO'

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
printf 'y n ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS --patch $KEEP_INDEX_FLAGS <.git/answers_for_patch
assert_outputs__create__success '1,1'
new_stash_sha_CO="$stdout"
assert_files_HTCO '
?? aaa		aaa
?? bbb		bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
?? bbb		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
?? aaa		aaa
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
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
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
