#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'ddd\n' >ddd
git stash push -u

git unstash
test "$(git diff --name-only --staged)" = 'aaa'
test "$(git diff --name-only)" = 'aaa'
test "$(git ls-files --others --exclude-standard)" = 'ddd'
test "$(git show :aaa)" = 'bbb'
test "$(cat aaa)" = 'ccc'
test "$(cat ddd)" = 'ddd'
