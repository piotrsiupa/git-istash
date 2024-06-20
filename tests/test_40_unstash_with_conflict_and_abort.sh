#!/usr/bin/env sh

set -e

cd "$1"

git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch -c branch1
printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

temp_file="$(mktemp)"
if git unstash 2>"$temp_file"
then
	rm -f "$temp_file"
	exit 1
fi
text="$(cat "$temp_file" | tail -n4)"
rm -f "$temp_file"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
test "$(git status --porcelain)" = 'UU aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1

git unstash --abort
test "$(git status --porcelain)" = ''
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'ddd'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
