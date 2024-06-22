#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'bbb\n' >aaa
earlier_stash_hash="$(git stash create 'earlier stash entry')"
git reset --hard

printf 'ccc\n' >aaa
git stash create 'later stash entry'
git reset --hard
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0

correct_head_hash="$(git rev-parse HEAD)"
git unstash "$earlier_stash_hash"
test "$(git status --porcelain)" = ' M aaa'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'bbb'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
