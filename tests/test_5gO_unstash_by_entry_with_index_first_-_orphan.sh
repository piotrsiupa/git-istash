set -e

printf 'bbb\n' >aaa
git stash push -u -m 'earlier stash entry'
earlier_stash_hash="$(git rev-parse 'stash@{0}')"

printf 'ccc\n' >aaa
git stash push -u -m 'later stash entry'

git switch --orphan ooo

git unstash 'stash@{0}'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = '?? aaa'
test "$(cat aaa)" = 'ccc'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-parse 'stash@{0}')" = "$earlier_stash_hash"
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
