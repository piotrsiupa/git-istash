. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

SWITCH_HEAD_TYPE

printf 'bbb\n' >bbb
git add bbb
printf 'ccc\n' >bbb
printf 'ddd\n' >ddd
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash push --message 'mesanmge'
assert_files_H '
?? ddd		ddd
!! ignored	ignored
'
assert_stash_H 0 'mesanmge' '
AM bbb		ccc	bbb
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n

RESTORE_HEAD_TYPE

assert_exit_code 0 git stash pop --index
assert_files '
AM bbb		ccc	bbb
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
