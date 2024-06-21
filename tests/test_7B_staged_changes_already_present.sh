#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the stash'

printf 'xxx\n' >aaa
git add aaa
if git unstash 1 ; then exit 1 ; fi
test "$(git status --porcelain)" = 'M  aaa'
test "$(git show :aaa)" = 'xxx'
test "$(cat aaa)" = 'xxx'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
