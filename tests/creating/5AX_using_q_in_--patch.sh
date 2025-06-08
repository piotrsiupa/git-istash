. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
printf 'xxx\n' >aaa
printf 'xxx\n' >bbb
git add aaa bbb
git commit -m 'Added some files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'yyy\n' >aaa
printf 'yyy\n' >bbb
printf 'yyy\n' >ccc
printf 'yyy\n' >ddd
printf 'q q y y y y ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS --patch $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS --allow-empty <.git/answers_for_patch
assert_files_HT '
 M aaa		yyy	xxx
 M bbb		yyy	xxx
?? ccc		yyy
?? ddd		yyy
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_HT 0 '' '
   aaa		xxx
   bbb		xxx
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
   aaa		xxx
   bbb		xxx
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
