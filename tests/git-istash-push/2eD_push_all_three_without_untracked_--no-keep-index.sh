. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git switch -d HEAD

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'ddd\n' >ddd
correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 0 git istash push --no-include-untracked --no-keep-index
assert_all_files 'aaa|ddd|ignored'
assert_tracked_files 'aaa'
assert_status '?? ddd'
assert_file_contents aaa 'aaa' 'aaa'
assert_file_contents ddd 'ddd'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n

git switch master

assert_exit_code 0 git stash pop --index
assert_all_files 'aaa|ddd|ignored'
assert_tracked_files 'aaa'
assert_status 'MM aaa|?? ddd'
assert_file_contents aaa 'ccc' 'bbb'
assert_file_contents ddd 'ddd'
assert_file_contents ignored 'ignored'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
