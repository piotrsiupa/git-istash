#!/usr/bin/env sh

set -e

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

printf 'bbb\n' >aaa
git stash push
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

correct_head_hash="$(git rev-parse HEAD)"
git stash pop
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ' M aaa'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'bbb'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'master'
