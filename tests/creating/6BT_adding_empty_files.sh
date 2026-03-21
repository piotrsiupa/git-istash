. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX 'NO'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_COLOR

__end_of_initialization__

prepare_repository
printf 'ccc\n' >>.git/info/exclude
rm ignored0 ignored1

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
touch aaa
git add aaa
touch bbb
touch ccc
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS -m 'emptiest stash ever' $ALL_FLAGS $UNTRACKED_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $COLOR_FLAGS
assert_outputs__create__success '*' 0 'emptiest stash ever'
new_stash_sha_CO="$stdout"
assert_files_HTCO '
A  aaa		""
?? bbb		""
!! ccc		""
' '
'
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 'emptiest stash ever' '
A  aaa		""
?? bbb		""
!! ccc		""
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
A  aaa		""
?? bbb		""
!! ccc		""
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
