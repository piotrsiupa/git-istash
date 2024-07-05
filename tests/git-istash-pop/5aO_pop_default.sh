. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git stash push -u -m 'earlier stash entry'
assert_stash_count 1
earlier_stash_hash="$(git rev-parse 'stash@{0}')"

printf 'ccc\n' >aaa
git stash push -u -m 'later stash entry'
assert_stash_count 2

git switch --orphan ooo

assert_exit_code 0 git istash-pop
assert_status '?? aaa'
assert_file_contents aaa 'ccc'
assert_stash_count 1
assert_stash_hash 0 "$earlier_stash_hash"
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
