#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0

printf 'bbb\n' >aaa
git stash push -m 'earlier stash entry'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
earlier_stash_hash="$(git rev-parse 'stash@{0}')"

printf 'ccc\n' >aaa
git stash push -m 'later stash entry'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 2

git unstash
test "$(git status --porcelain)" = ' M aaa'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'ccc'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-parse 'stash@{0}')" = "$earlier_stash_hash"
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
