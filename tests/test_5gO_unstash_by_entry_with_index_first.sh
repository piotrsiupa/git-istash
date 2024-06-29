. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git stash push -u -m 'earlier stash entry'
earlier_stash_hash="$(git rev-parse 'stash@{0}')"

printf 'ccc\n' >aaa
git stash push -u -m 'later stash entry'

git switch --orphan ooo

assert_success git unstash 'stash@{0}'
assert_status '?? aaa'
assert_file_contents aaa 'ccc'
assert_stash_count 1
assert_stash_hash 0 "$earlier_stash_hash"
assert_branch_count 1
assert_head_name '~ooo'
