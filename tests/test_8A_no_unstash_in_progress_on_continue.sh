#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the only stash'

if git unstash --continue ; then exit 1 ; fi
test "$(git status --porcelain)" = ''
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
if git unstash --continue ; then exit 1 ; fi
test "$(git status --porcelain)" = 'MM aaa'
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'eee'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
