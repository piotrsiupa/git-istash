. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git rm aaa
printf 'bbb\n' >aaa
git stash push -u

SWITCH_HEAD_TYPE

correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash apply
assert_files_H '
D  aaa
?? aaa		bbb
!! ignored	ignored
' '
?? aaa		bbb
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
