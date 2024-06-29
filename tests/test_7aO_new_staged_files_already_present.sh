set -e

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the stash'

git switch --orphan ooo

printf 'xxx\n' >xxx
git add xxx
if git istash 1 ; then exit 1 ; fi
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'A  xxx'
test "$(git show :xxx)" = 'xxx'
test "$(cat xxx)" = 'xxx'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
