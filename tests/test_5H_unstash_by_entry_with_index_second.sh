#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'bbb\n' >aaa
git stash push -m 'earlier stash entry'

printf 'ccc\n' >aaa
git stash push -m 'later stash entry'
later_stash_hash="$(git rev-parse 'stash@{0}')"

correct_head_hash="$(git rev-parse HEAD)"
git unstash 'stash@{1}'
test "$(git status --porcelain)" = ' M aaa'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'bbb'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-parse 'stash@{0}')" = "$later_stash_hash"
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'master'
