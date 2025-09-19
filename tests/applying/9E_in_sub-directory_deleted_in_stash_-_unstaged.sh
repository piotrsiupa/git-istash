. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
mkdir 'aaa'
printf 'foo\n' >aaa/bbb
printf 'foo\n' >ccc
git add aaa/bbb ccc
git commit -m 'Added aaa/bbb & ccc'

__test_section__ 'Create stash'
rm -r aaa
git stash push

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
cd aaa
assert_exit_code 0 git istash "$APPLY_OPERATION"
cd -
assert_files_HT '
 D aaa/bbb	foo
   ccc		foo
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
