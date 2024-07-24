. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git stash push -u -m 'earlier stash entry'
git stash drop
git reset --hard

printf 'ccc\n' >aaa
git stash push -u -m 'later stash entry'
later_stash_hash="$(git rev-parse stash)"
git stash drop
git reset --hard
assert_stash_count 0

git switch --orphan ooo

assert_exit_code 1 git istash pop "$later_stash_hash"
assert_all_files 'ignored'
assert_status ''
assert_file_contents ignored 'ignored'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
