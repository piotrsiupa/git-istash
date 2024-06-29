. "$(dirname "$0")/commons.sh" 1>/dev/null

git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch -c branch1
git commit --allow-empty -m 'Changed nothing'

git switch branch0
git merge branch1 --no-ff --no-commit
assert_tracked_files 'aaa'
assert_status ''
assert_stash_count 1
assert_file_contents aaa 'aaa' 'aaa'
assert_log_length 2
assert_branch_count 2

correct_head_hash="$(git rev-parse HEAD)"
assert_failure git unstash
assert_tracked_files 'aaa'
assert_status ''
assert_stash_count 1
assert_file_contents aaa 'aaa' 'aaa'
assert_log_length 2
assert_branch_count 2
assert_head_hash "$correct_head_hash"
