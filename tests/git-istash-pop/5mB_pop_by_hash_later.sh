. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'bbb\n' >aaa
git stash create 'earlier stash entry'
git reset --hard

printf 'ccc\n' >aaa
later_stash_hash="$(git stash create 'later stash entry')"
git reset --hard
assert_stash_count 0

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 1 git istash pop "$later_stash_hash"
assert_all_files 'aaa|ignored'
assert_tracked_files 'aaa'
assert_status ''
assert_file_contents aaa 'aaa' 'aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
