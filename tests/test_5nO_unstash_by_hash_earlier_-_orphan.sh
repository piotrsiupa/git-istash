set -e

printf 'bbb\n' >aaa
git stash push -u -m 'earlier stash entry'
earlier_stash_hash="$(git rev-parse stash)"
git stash drop
git reset --hard

printf 'ccc\n' >aaa
git stash push -u -m 'later stash entry'
git stash drop
git reset --hard
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0

git switch --orphan ooo

git unstash "$earlier_stash_hash"
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = '?? aaa'
test "$(cat aaa)" = 'bbb'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
