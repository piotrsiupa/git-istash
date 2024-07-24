. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push

git switch --orphan ooo

assert_exit_code 2 capture_outputs git istash apply
assert_conflict_message git istash apply
assert_all_files 'aaa|ignored'
assert_status 'DU aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'apply'
assert_rebase y

printf 'eee\n' >aaa
assert_exit_code 2 capture_outputs git istash apply --continue
assert_conflict_message git istash apply
assert_all_files 'aaa|ignored'
assert_status 'DU aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'apply'
assert_rebase y

git add aaa
assert_exit_code 2 capture_outputs git istash apply --continue
assert_conflict_message git istash apply --continue
assert_all_files 'aaa|ignored'
assert_status 'UU aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'apply'
assert_rebase y

printf 'fff\n' >aaa
assert_exit_code 2 capture_outputs git istash apply --continue
assert_conflict_message git istash apply --continue
assert_all_files 'aaa|ignored'
assert_status 'UU aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'apply'
assert_rebase y

git add aaa
assert_exit_code 0 git istash apply --continue
assert_all_files 'aaa|ignored'
assert_status 'AM aaa'
assert_file_contents aaa 'fff' 'eee'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
