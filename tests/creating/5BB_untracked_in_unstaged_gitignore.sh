. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
printf 'X' >.gitignore
git add .gitignore
git commit -m 'Added empty ".gitignore"'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
printf 'aaa\n' >.gitignore
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $UNTRACKED_FLAGS $ALL_FLAGS -mX
assert_files_HT '
   .gitignore	X
?? aaa		aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_HT 0 'X' '
 M .gitignore	aaa	X
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

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
 M .gitignore	aaa	X
!! aaa		aaa
?? bbb		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
