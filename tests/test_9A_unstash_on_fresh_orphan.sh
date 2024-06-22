#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'ddd\n' >ddd
git stash push -u

git switch --orphan ooo

git unstash
test "$(git status --porcelain)" = '?? ddd'
test "$(cat ddd)" = 'ddd'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git branch --show-current)" = 'ooo'
