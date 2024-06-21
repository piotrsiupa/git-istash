#!/usr/bin/env sh

set -e

cd "$1"

git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch -c branch1
git commit --allow-empty -m 'Changed nothing'

git switch branch0
git merge branch1 --no-ff --no-commit
test "$(git status --porcelain)" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'

if git unstash ; then exit 1 ; fi
test "$(git status --porcelain)" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
