. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH'

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ccc\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 2 capture_outputs git istash apply
assert_conflict_message git istash apply
assert_files_H '
UU aaa		ccc|bbb
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'apply'
assert_rebase y

master_hash="$(git rev-parse master)"
git branch -D master
assert_exit_code 1 git istash apply --abort
assert_all_files 'aaa|ignored'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 0
assert_data_files 'apply'
assert_rebase y

git branch master "$master_hash"
assert_exit_code 0 git istash apply --abort
assert_files_H '
   aaa		ccc
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
