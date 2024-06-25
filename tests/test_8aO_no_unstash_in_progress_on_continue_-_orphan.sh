#!/usr/bin/env sh

set -e

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the only stash'

git switch --orphan ooo

if git unstash --continue ; then exit 1 ; fi
test "$(git status --porcelain)" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
if git unstash --continue ; then exit 1 ; fi
test "$(git status --porcelain)" = 'AM aaa'
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'eee'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
