. "$commons_path" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push -m 'the stash'
assert_branch_count 1
assert_dotgit_contents

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
printf 'xxx\n' >aaa
assert_exit_code 1 git istash "$APPLY_OPERATION" 1
assert_files_HT '
 M aaa		xxx	aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
