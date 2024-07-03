. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the only stash'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
assert_failure git istash-apply HEAD^
assert_tracked_files 'aaa'
assert_status ''
assert_file_contents aaa 'aaa' 'aaa'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_data_files 'none'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
assert_failure git istash-apply HEAD^
assert_tracked_files 'aaa'
assert_status 'MM aaa'
assert_file_contents aaa 'eee' 'ddd'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
