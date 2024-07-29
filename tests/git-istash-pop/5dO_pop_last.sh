. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git stash push -u -m 'earlier stash entry'

printf 'ccc\n' >aaa
git stash push -u -m 'later stash entry'
later_stash_hash="$(git rev-parse 'stash@{0}')"

git switch --orphan ooo

assert_exit_code 0 git istash pop -- -1
assert_files '
?? aaa		bbb
!! ignored	ignored
'
assert_stash_count 1
assert_stash_hash 0 "$later_stash_hash"
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
