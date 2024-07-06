. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git add aaa
git stash push
assert_status ''
assert_stash_count 1
assert_log_length 1
assert_branch_count 1
assert_data_files 'none'
assert_rebase n

git switch --orphan ooo

assert_exit_code 0 git stash pop
assert_status 'A  aaa'
assert_file_contents aaa 'bbb' 'bbb'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
