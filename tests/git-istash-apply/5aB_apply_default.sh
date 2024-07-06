. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'
assert_stash_count 0

printf 'bbb\n' >aaa
git stash push -m 'earlier stash entry'
assert_stash_count 1

printf 'ccc\n' >aaa
git stash push -m 'later stash entry'
assert_stash_count 2

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 0 git istash apply
assert_tracked_files 'aaa'
assert_status ' M aaa'
assert_file_contents aaa 'ccc' 'aaa'
assert_stash_count 2
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
