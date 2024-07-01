. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'bbb\n' >aaa
git stash push -m 'earlier stash entry'

printf 'ccc\n' >aaa
git stash push -m 'later stash entry'
later_stash_hash="$(git rev-parse 'stash@{0}')"

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
assert_success git istash-pop -- -1
assert_tracked_files 'aaa'
assert_status ' M aaa'
assert_file_contents aaa 'bbb' 'aaa'
assert_stash_count 1
assert_stash_hash 0 "$later_stash_hash"
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
