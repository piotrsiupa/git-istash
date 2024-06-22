#!/usr/bin/env sh

set -e

cd "$1"

git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'zzz\n' >zzz
git stash push -u

git switch -c branch1
printf 'ddd\n' >aaa
printf 'yyy\n' >zzz
git add aaa zzz
git commit -m 'Changed aaa & added zzz'

temp_file="$(mktemp)"
if git unstash 2>"$temp_file"
then
	rm -f "$temp_file"
	exit 1
fi
text="$(tail -n4 <"$temp_file")"
rm -f "$temp_file"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
test "$(git status --porcelain)" = 'UU aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1

printf 'eee\n' >aaa
git add aaa
temp_file="$(mktemp)"
if git unstash --continue 2>"$temp_file"
then
	rm -f "$temp_file"
	exit 1
fi
text="$(tail -n4 <"$temp_file")"
rm -f "$temp_file"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
test "$(git status --porcelain)" = \
'UU aaa
AA zzz'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1

git unstash --abort
test "$(git status --porcelain)" = ''
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'ddd'
test "$(git show :zzz)" = 'yyy'
test "$(cat zzz)" = 'yyy'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-list --count HEAD)" -eq 3
