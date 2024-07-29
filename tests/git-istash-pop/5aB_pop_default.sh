. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'
assert_stash_count 0

printf 'bbb\n' >aaa
git stash push -m 'earlier stash entry'
assert_stash_count 1
earlier_stash_hash="$(git rev-parse 'stash@{0}')"

printf 'ccc\n' >aaa
git stash push -m 'later stash entry'
assert_stash_count 2

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 0 git istash pop
assert_files '
 M aaa		ccc	aaa
!! ignored	ignored
'
assert_stash_count 1
assert_stash_hash 0 "$earlier_stash_hash"
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
