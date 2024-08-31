. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push -m 'the stash'
assert_branch_count 1

SWITCH_HEAD_TYPE

correct_head_hash="$(get_head_hash_H)"
printf 'xxx\n' >aaa
assert_exit_code 1 git istash apply 1
assert_files_H '
 M aaa		xxx	aaa
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
