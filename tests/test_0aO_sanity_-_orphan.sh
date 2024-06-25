#!/usr/bin/env sh

set -e

printf 'bbb\n' >aaa
git add aaa
git stash push
test "$(git status --porcelain)" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-list --count HEAD)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

git switch --orphan ooo

git stash pop
test "$(git status --porcelain)" = 'A  aaa'
test "$(git show :aaa)" = 'bbb'
test "$(cat aaa)" = 'bbb'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
