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

correct_head_hash="$(git rev-parse HEAD)"
if git unstash 0 0 ; then exit 1 ; fi
test "$(git status --porcelain)" = ''
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
if git unstash 0 0 ; then exit 1 ; fi
test "$(git status --porcelain)" = 'MM aaa'
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'eee'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
