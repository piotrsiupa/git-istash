#!/usr/bin/env sh

set -e

cd "$1"

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git unstash
test "$(git ls-files --others --exclude-standard)" = ''
test "$(git diff --name-only --staged)" = ''
test "$(git diff --name-only)" = 'aaa'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'bbb'
