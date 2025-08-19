. "$commons_path" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
git stash push -m 'the only stash'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash (without changes)"
correct_head_hash="$(get_head_hash_HT)"
assert_exit_code 1 git istash "$APPLY_OPERATION" "stash@{1}"
assert_files_HT '
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents

__test_section__ "$CAP_APPLY_OPERATION stash (with changes)"
printf 'ccc\n' >aaa
git add aaa
printf 'ddd\n' >aaa
assert_exit_code 1 git istash "$APPLY_OPERATION" "stash@{1}"
assert_files_HT '
AM aaa		ddd	ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_name_HT
assert_head_hash_HT "$correct_head_hash"
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
