. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
git stash push -m 'the stash'
assert_branch_count 1

SWITCH_HEAD_TYPE

__test_section__ 'Pop stash'
correct_head_hash="$(get_head_hash_H)"
printf 'xxx\n' >xxx
assert_exit_code 1 git istash pop 1
assert_files_H '
?? xxx		xxx
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
