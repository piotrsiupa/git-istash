. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the only stash'

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 1 git istash-apply 'non_existent_branch'
assert_tracked_files 'aaa'
assert_status ''
assert_file_contents aaa 'aaa' 'aaa'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
assert_exit_code 1 git istash-apply 'non_existent_branch'
assert_tracked_files 'aaa'
assert_status 'MM aaa'
assert_file_contents aaa 'eee' 'ddd'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
