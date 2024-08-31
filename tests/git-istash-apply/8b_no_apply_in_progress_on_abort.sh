. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
git stash push -m 'the only stash'

SWITCH_HEAD_TYPE

correct_head_hash="$(get_head_hash_H)"
assert_exit_code 1 git istash apply --abort
assert_files_H '
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n

printf 'ccc\n' >aaa
git add aaa
printf 'ddd\n' >aaa
assert_exit_code 1 git istash apply --abort
assert_files_H '
AM aaa		ddd	ccc
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
