. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the stash'
assert_branch_count 1

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
printf 'xxx\n' >xxx
assert_failure git unstash 1
assert_tracked_files 'aaa'
assert_status '?? xxx'
assert_file_contents aaa 'aaa' 'aaa'
assert_file_contents xxx 'xxx'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
