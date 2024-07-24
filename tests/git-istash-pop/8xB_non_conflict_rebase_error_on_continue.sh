. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

assert_exit_code 2 capture_outputs git istash pop
assert_conflict_message git istash pop
assert_all_files 'aaa|ignored'
assert_tracked_files 'aaa'
assert_status 'UU aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'pop'
assert_rebase y

printf 'eee\n' >aaa
git add aaa
rm -rf '.git/rebase-apply' '.git/rebase-merge'
assert_exit_code 1 git istash pop --continue
assert_all_files 'aaa|ignored'
assert_tracked_files 'aaa'
assert_status 'M  aaa'
assert_file_contents aaa 'eee' 'eee'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 1
assert_head_name 'HEAD'
assert_data_files 'pop'
