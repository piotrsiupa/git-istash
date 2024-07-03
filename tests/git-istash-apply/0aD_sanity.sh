. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
assert_tracked_files 'aaa'
assert_status ''
assert_file_contents aaa 'aaa' 'aaa'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_data_files 'none'

printf 'bbb\n' >aaa
git stash push
assert_tracked_files 'aaa'
assert_status ''
assert_file_contents aaa 'aaa' 'aaa'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_data_files 'none'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
assert_success git stash apply
assert_tracked_files 'aaa'
assert_status ' M aaa'
assert_file_contents aaa 'bbb' 'aaa'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
