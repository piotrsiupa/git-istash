#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push

git unstash
test "$(git status --porcelain)" = 'MM aaa'
test "$(git show :aaa)" = 'bbb'
test "$(cat aaa)" = 'ccc'
