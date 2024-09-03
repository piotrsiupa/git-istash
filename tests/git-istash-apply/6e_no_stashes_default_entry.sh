. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

SWITCH_HEAD_TYPE

__test_section__ 'Apply stash (without changes)'
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 1 git istash apply 'stash'
assert_files_H '
!! ignored	ignored
'
assert_stash_count 0
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n

__test_section__ 'Apply stash (with changes)'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
assert_exit_code 1 git istash apply 'stash'
assert_files_H '
AM aaa		bbb	aaa
!! ignored	ignored
'
assert_stash_count 0
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
