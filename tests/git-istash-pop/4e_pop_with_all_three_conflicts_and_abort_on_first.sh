. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'zzz\n' >zzz
git stash push -u

printf 'ddd\n' >aaa
printf 'yyy\n' >zzz
git add aaa zzz
git commit -m 'Changed aaa & added zzz'

SWITCH_HEAD_TYPE

correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash pop
assert_conflict_message git istash pop
assert_files_H '
UU aaa		ddd|bbb
   zzz		yyy
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files 'pop'
assert_rebase y

assert_exit_code 0 git istash pop --abort
assert_files_H '
   aaa		ddd
   zzz		yyy
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
