. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ccc\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash apply
assert_conflict_message git istash apply
assert_files_H '
UU aaa		ccc|bbb
!! ignored	ignored
' '
DU aaa		bbb
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files 'apply'
assert_rebase y

correct_head_hash2="$(get_head_hash_H)"
printf 'ddd\n' >aaa
git add aaa
assert_exit_code 1 git istash apply --continue 0
assert_files_H '
M  aaa		ddd
!! ignored	ignored
' '
A  aaa		ddd
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_head_hash_H "$correct_head_hash2"
assert_data_files 'apply'
assert_rebase y

assert_exit_code 0 git istash apply --continue
assert_files_H '
 M aaa		ddd	ccc
!! ignored	ignored
' '
?? aaa		ddd
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
