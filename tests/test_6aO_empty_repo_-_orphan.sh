#!/usr/bin/env sh

set -e

rm -rf ./.git
git init

git switch --orphan ooo

if git unstash ; then exit 1 ; fi
test "$(git status --porcelain)" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
if git rev-parse HEAD ; then exit 1 ; fi

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
if git unstash ; then exit 1 ; fi
test "$(git status --porcelain)" = 'AM aaa'
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'eee'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 0
test "$(git branch --show-current)" = 'ooo'
