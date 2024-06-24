#!/usr/bin/env sh

set -e

. "$(dirname "$0")/utils.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'zzz\n' >zzz
git stash push -u

git switch --orphan ooo

if run_and_capture git unstash ; then exit 1 ; fi
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
test "$(git status --porcelain)" = 'DU aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2

printf 'eee\n' >aaa
git add aaa
if run_and_capture git unstash --continue ; then exit 1 ; fi
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
test "$(git status --porcelain)" = \
'UU aaa
A  zzz'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2

printf 'fff\n' >aaa
printf 'xxx\n' >zzz
git add aaa zzz
git unstash --continue
test "$(git status --porcelain)" = \
'AM aaa
?? zzz'
test "$(git show :aaa)" = 'eee'
test "$(cat aaa)" = 'fff'
test "$(cat zzz)" = 'xxx'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git branch --show-current)" = 'ooo'
