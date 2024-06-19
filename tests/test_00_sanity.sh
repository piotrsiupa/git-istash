#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
git diff --quiet HEAD

printf 'bbb\n' >aaa
git stash push
git diff --quiet HEAD
test "$(cat aaa)" = 'aaa'

git stash pop
test "$(git status --porcelain)" = ' M aaa'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'bbb'
