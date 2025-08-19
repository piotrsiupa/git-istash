. "$commons_path" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git stash push

__test_section__ 'Create a commit to merge'
git switch -c branch1
git commit --allow-empty -m 'Changed nothing'

git switch branch0
SWITCH_HEAD_TYPE

__test_section__ 'Merge branch'
git merge branch1 --no-ff --no-commit
assert_files_HT '
   aaa		aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 2
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
assert_exit_code 1 git istash "$APPLY_OPERATION"
assert_files_HT '
   aaa		aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 2
assert_head_hash_HT "$correct_head_hash"
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents

__test_section__ "Continue merge"
GIT_EDITOR='true' git merge --continue
assert_files_HT '
   aaa		aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 4
assert_branch_count 2
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
