. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

correct_head_hash="$(git rev-parse HEAD)"
assert_failure capture_outputs git istash-pop
assert_conflict_message git istash-pop
assert_tracked_files 'aaa'
assert_status 'UU aaa'
assert_stash_count 1
assert_branch_count 1

master_hash="$(git rev-parse master)"
git branch -D master
assert_failure git istash-pop --abort
assert_branch_count 0

git branch master "$master_hash"
assert_success git istash-pop --abort
assert_tracked_files 'aaa'
assert_status ''
assert_file_contents aaa 'ddd' 'ddd'
assert_stash_count 1
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
