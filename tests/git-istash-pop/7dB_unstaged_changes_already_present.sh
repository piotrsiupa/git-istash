. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the stash'
assert_branch_count 1

correct_head_hash="$(git rev-parse HEAD)"
printf 'xxx\n' >aaa
assert_exit_code 1 git istash pop 1
assert_tracked_files 'aaa'
assert_status ' M aaa'
assert_file_contents aaa 'xxx' 'aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
