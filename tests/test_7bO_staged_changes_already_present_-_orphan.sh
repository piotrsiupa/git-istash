set -e

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the stash'
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

git switch --orphan ooo

printf 'xxx\n' >aaa
git add aaa
if git unstash 1 ; then exit 1 ; fi
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'A  aaa'
test "$(git show :aaa)" = 'xxx'
test "$(cat aaa)" = 'xxx'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
