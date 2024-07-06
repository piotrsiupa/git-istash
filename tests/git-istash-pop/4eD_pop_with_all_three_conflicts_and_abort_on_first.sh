. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'zzz\n' >zzz
git stash push -u

printf 'ddd\n' >aaa
printf 'yyy\n' >zzz
git add aaa zzz
git commit -m 'Changed aaa & added zzz'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 2 capture_outputs git istash-pop
assert_conflict_message git istash-pop
assert_tracked_files 'aaa|zzz'
assert_status 'UU aaa'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'pop'
assert_rebase y

assert_exit_code 0 git istash-pop --abort
assert_tracked_files 'aaa|zzz'
assert_status ''
assert_file_contents aaa 'ddd' 'ddd'
assert_file_contents zzz 'yyy' 'yyy'
assert_stash_count 1
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n
