#!/usr/bin/env sh

set -e

. "$(dirname "$0")/utils.sh" 1>/dev/null

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

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
if run_and_capture git unstash ; then exit 1 ; fi
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'UU aaa'
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
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'UU aaa|AA zzz'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2

printf 'fff\n' >aaa
printf 'xxx\n' >zzz
git add aaa zzz
git unstash --continue
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'MM aaa| M zzz'
test "$(git show :aaa)" = 'eee'
test "$(cat aaa)" = 'fff'
test "$(git show :zzz)" = 'yyy'
test "$(cat zzz)" = 'xxx'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 3
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'HEAD'
