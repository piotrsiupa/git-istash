#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the stash'

correct_head_hash="$(git rev-parse HEAD)"
printf 'xxx\n' >xxx
git add xxx
if git unstash 1 ; then exit 1 ; fi
test "$(git status --porcelain)" = 'A  xxx'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'aaa'
test "$(git show :xxx)" = 'xxx'
test "$(cat xxx)" = 'xxx'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'master'
