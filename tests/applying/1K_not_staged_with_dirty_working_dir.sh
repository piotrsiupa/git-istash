. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
git add aaa bbb
git commit -m 'Added aaa & bbb'

__test_section__ 'Create stash'
printf 'xxx\n' >aaa
git stash push

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory'
printf 'yyy\n' >bbb

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash)"
assert_exit_code 0 git istash "$APPLY_OPERATION"
assert_files_HT '
 M aaa		xxx	aaa
 M bbb		yyy	bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
