#!/usr/bin/env sh

set -e

cd "$1"

git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push

git switch -c branch1
printf 'bbb\n' >aaa
git commit -am 'Changed aaa'

git unstash
test "$(git status --porcelain)" = ' M aaa'
test "$(git show :aaa)" = 'bbb'
test "$(cat aaa)" = 'ccc'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
