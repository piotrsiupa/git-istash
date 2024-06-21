#!/usr/bin/env sh

set -e

cd "$1"

rm -rf ./.git
git init

if git unstash ; then exit 1 ; fi
test "$(git status --porcelain)" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
if git unstash ; then exit 1 ; fi
test "$(git status --porcelain)" = 'AM aaa'
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'eee'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
