#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

if git unstash ; then exit 1 ; fi
test "$(git status --porcelain)" = ''
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 2

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
if git unstash ; then exit 1 ; fi
test "$(git status --porcelain)" = 'MM aaa'
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'eee'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 2
