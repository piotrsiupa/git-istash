. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

printf 'aaa\n' >aaa
git stash push -u -m 'earlier stash entry'

printf 'bbb\n' >bbb
git stash push -u -m 'later stash entry'
later_stash_hash="$(get_stash_hash)"

SWITCH_HEAD_TYPE

correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash pop -- 'stash^{/earlier}'
assert_files_H '
?? aaa		aaa
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_stash_hash 0 "$later_stash_hash"
