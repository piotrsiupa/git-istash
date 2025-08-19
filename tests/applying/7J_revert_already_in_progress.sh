. "$commons_path" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git stash push

__test_section__ 'Create a few commits'
printf 'ccc\n' >aaa
git add aaa
git commit -m 'Changed something'
printf 'ddd\n' >aaa
git add aaa
git commit -m 'Changed something again'

SWITCH_HEAD_TYPE

__test_section__ 'Revert commit'
git revert HEAD~1 || true
assert_files_HT '
UU aaa		ddd|aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 4
assert_branch_count 1
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
assert_exit_code 1 git istash "$APPLY_OPERATION"
assert_files_HT '
UU aaa		ddd|aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 4
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents

__test_section__ 'Continue revert'
printf 'eee\n' >aaa
git add aaa
git revert --continue
assert_files_HT '
   aaa		eee
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 5
assert_branch_count 1
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
