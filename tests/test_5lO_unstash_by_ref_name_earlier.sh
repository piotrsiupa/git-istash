. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git stash push -u -m 'earlier stash entry'
git branch earlier stash
git stash drop
git reset --hard

printf 'ccc\n' >aaa
git stash push -u -m 'later stash entry'
git branch later stash
git stash drop
git reset --hard
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0

git switch --orphan ooo

git unstash earlier
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = '?? aaa'
test "$(cat aaa)" = 'bbb'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 3
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
