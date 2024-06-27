set -e

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push

git switch --orphan ooo

git istash
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'AM aaa'
test "$(git show :aaa)" = 'bbb'
test "$(cat aaa)" = 'ccc'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
