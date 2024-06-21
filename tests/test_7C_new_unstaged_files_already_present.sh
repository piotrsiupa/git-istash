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

printf 'xxx\n' >xxx
git add -N xxx
if git unstash 1 ; then exit 1 ; fi
test "$(git status --porcelain)" = ' A xxx'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(cat xxx)" = 'xxx'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
