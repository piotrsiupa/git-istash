. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

# We don't need those in this test.
rm ignored0 ignored1

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
mkdir -p 'a/0' 'a/1' 'b/0' 'b/1'
printf 'xxx\n' >'a/0/i'
printf 'xxx\n' >'a/0/j'
printf 'xxx\n' >'a/1/i'
printf 'xxx\n' >'a/1/j'
printf 'xxx\n' >'b/0/i'
printf 'xxx\n' >'b/0/j'
printf 'xxx\n' >'b/1/i'
printf 'xxx\n' >'b/1/j'
cd 'a'
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS
cd -
assert_outputs__create__success
new_stash_sha_CO="$stdout"
assert_files_HTCO '
?? a/0/i	xxx
?? a/0/j	xxx
?? a/1/i	xxx
?? a/1/j	xxx
?? b/0/i	xxx
?? b/0/j	xxx
?? b/1/i	xxx
?? b/1/j	xxx
' '
'
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
?? a/0/i	xxx
?? a/0/j	xxx
?? a/1/i	xxx
?? a/1/j	xxx
?? b/0/i	xxx
?? b/0/j	xxx
?? b/1/i	xxx
?? b/1/j	xxx
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
?? a/0/i	xxx
?? a/0/j	xxx
?? a/1/i	xxx
?? a/1/j	xxx
?? b/0/i	xxx
?? b/0/j	xxx
?? b/1/i	xxx
?? b/1/j	xxx
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
