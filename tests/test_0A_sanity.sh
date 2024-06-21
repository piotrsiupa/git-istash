#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
test "$(git status --porcelain)" = ''
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0

printf 'bbb\n' >aaa
git stash push
test "$(git status --porcelain)" = ''
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1

git stash pop
test "$(git status --porcelain)" = ' M aaa'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'bbb'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
