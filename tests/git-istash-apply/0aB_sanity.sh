. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
assert_all_files 'aaa|ignored'
assert_tracked_files 'aaa'
assert_status ''
assert_file_contents aaa 'aaa' 'aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_data_files 'none'
assert_rebase n

printf 'bbb\n' >aaa
git stash push
assert_all_files 'aaa|ignored'
assert_tracked_files 'aaa'
assert_status ''
assert_file_contents aaa 'aaa' 'aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_data_files 'none'
assert_rebase n

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 0 git stash apply
assert_all_files 'aaa|ignored'
assert_tracked_files 'aaa'
assert_status ' M aaa'
assert_file_contents aaa 'bbb' 'aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
