. "$(dirname "$0")/../commons.sh" 1>/dev/null

git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch -c branch1
printf 'xxx\n' >xxx
git add xxx
git commit -m 'Changed xxx'

git switch -d HEAD

git rebase branch0 --exec='return 1' || true
assert_tracked_files 'aaa|xxx'
assert_status ''
assert_stash_count 1
assert_file_contents aaa 'aaa' 'aaa'
assert_file_contents xxx 'xxx' 'xxx'
assert_branch_count 2
assert_data_files 'none'
assert_rebase y

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 1 git istash-pop
assert_tracked_files 'aaa|xxx'
assert_status ''
assert_stash_count 1
assert_file_contents aaa 'aaa' 'aaa'
assert_file_contents xxx 'xxx' 'xxx'
assert_branch_count 2
assert_head_hash "$correct_head_hash"
assert_data_files 'none'
assert_rebase y
