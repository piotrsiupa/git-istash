#!/usr/bin/env sh

set -e

git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch -c branch1
printf 'xxx\n' >xxx
git add xxx
git commit -m 'Changed xxx'

git rebase branch0 --exec='return 1' || true
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|xxx'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git show :xxx)" = 'xxx'
test "$(cat xxx)" = 'xxx'
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2

correct_head_hash="$(git rev-parse HEAD)"
if git unstash ; then exit 1 ; fi
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|xxx'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git show :xxx)" = 'xxx'
test "$(cat xxx)" = 'xxx'
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2
test "$(git rev-parse HEAD)" = "$correct_head_hash"
