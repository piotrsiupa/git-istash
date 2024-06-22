#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

correct_head_hash="$(git rev-parse HEAD)"
git unstash
test "$(git status --porcelain)" = ' M aaa'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'bbb'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
