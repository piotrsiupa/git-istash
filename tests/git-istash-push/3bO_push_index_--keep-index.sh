. "$(dirname "$0")/../commons.sh" 1>/dev/null

git switch --orphan ooo

printf 'bbb\n' >aaa
git add aaa
assert_exit_code 0 git istash push --keep-index
assert_all_files 'aaa|ignored'
assert_status 'A  aaa'
assert_file_contents aaa 'bbb' 'bbb'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n

git reset --hard
git switch master

assert_exit_code 0 git stash pop --index
assert_all_files 'aaa|ignored'
assert_tracked_files ''
assert_status 'A  aaa'
assert_file_contents aaa 'bbb' 'bbb'
assert_file_contents ignored 'ignored'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
