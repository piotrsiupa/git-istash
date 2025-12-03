. "$(dirname "$0")/../commons.sh" 1>/dev/null

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

__test_section__ 'Start bisect'
correct_head_sha_0="$(get_head_sha_HT)"
git bisect start
git bisect bad
git bisect good HEAD~2
assert_files_HT '
   aaa		ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 3
assert_branch_count 1
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha_1="$(get_head_sha_HT)"
assert_exit_code 1 git istash "$APPLY_OPERATION"
assert_files_HT '
   aaa		ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 3
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha_1"
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents

__test_section__ 'Reset bisect'
git bisect reset
assert_files_HT '
   aaa		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 4
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha_0"
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
