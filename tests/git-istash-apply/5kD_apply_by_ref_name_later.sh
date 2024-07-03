. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'bbb\n' >aaa
git branch earlier "$(git stash create 'earlier stash entry')"
git reset --hard

printf 'ccc\n' >aaa
git branch later "$(git stash create 'later stash entry')"
git reset --hard
assert_stash_count 0

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
assert_success git istash-apply later
assert_tracked_files 'aaa'
assert_status ' M aaa'
assert_file_contents aaa 'ccc' 'aaa'
assert_stash_count 0
assert_log_length 2
assert_branch_count 3
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
