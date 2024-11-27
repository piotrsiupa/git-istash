. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
git stash push -m 'the only stash'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash (without changes)"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 1 git istash "$OPERATION" 0 0
assert_files_H '
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n

__test_section__ "$CAP_OPERATION stash (with changes)"
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
assert_exit_code 1 git istash "$OPERATION" 0 0
assert_files_H '
AM aaa		bbb	aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_H
