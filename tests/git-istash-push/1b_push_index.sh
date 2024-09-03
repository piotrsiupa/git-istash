. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash push -m 'new stash'
assert_files_H '
!! ignored	ignored
'
assert_stash_H 0 'new stash' '
A  aaa		bbb
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n

RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
A  aaa		bbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
