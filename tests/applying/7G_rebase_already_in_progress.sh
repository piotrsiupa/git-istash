. "$(dirname "$0")/../commons.sh" 1>/dev/null

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

__test_section__ 'Create conflict'
git switch -c branch1
printf 'xxx\n' >xxx
git add xxx
git commit -m 'Changed xxx'

SWITCH_HEAD_TYPE

__test_section__ 'Rebase branch'
git rebase branch0 --exec='return 1' || true
assert_files_HT '
   aaa		aaa
   xxx		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'none'
assert_rebase y
assert_dotgit_contents

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
assert_exit_code 1 git istash "$APPLY_OPERATION"
assert_files_HT '
   aaa		aaa
   xxx		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count 2
assert_head_hash_HT "$correct_head_hash"
assert_data_files 'none'
assert_rebase y
assert_branch_metadata_HT
assert_dotgit_contents
