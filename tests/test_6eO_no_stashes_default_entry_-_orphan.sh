#!/usr/bin/env sh

set -e

git switch --orphan ooo

if git unstash stash ; then exit 1 ; fi
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
if git unstash stash ; then exit 1 ; fi
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'AM aaa'
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'eee'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
