#!/usr/bin/env sh

set -e

. "$(dirname "$0")/utils.sh" 1>/dev/null

mkdir xxx yyy
printf 'aaa0\n' >aaa
printf 'aaa1\n' >xxx/aaa
printf 'aaa2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
git commit -m 'Added aaa'

printf 'bbb0\n' >aaa
printf 'bbb1\n' >xxx/aaa
printf 'bbb2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
printf 'ccc0\n' >aaa
printf 'ccc1\n' >xxx/aaa
printf 'ccc2\n' >yyy/aaa
printf 'zzz0\n' >zzz
printf 'zzz1\n' >xxx/zzz
printf 'zzz2\n' >yyy/zzz
git stash push -u

printf 'ddd0\n' >aaa
printf 'ddd1\n' >xxx/aaa
printf 'ddd2\n' >yyy/aaa
printf 'yyy0\n' >zzz
printf 'yyy1\n' >xxx/zzz
printf 'yyy2\n' >yyy/zzz
git add aaa xxx/aaa yyy/aaa zzz xxx/zzz yyy/zzz
git commit -m 'Changed aaa & added zzz'

correct_head_hash="$(git rev-parse HEAD)"
cd ./xxx
if run_and_capture git unstash ; then exit 1 ; fi
cd ..
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'UU aaa|UU xxx/aaa|UU yyy/aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd ./xxx
if run_and_capture git unstash --continue ; then exit 1 ; fi
cd ..
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|xxx/aaa|xxx/zzz|yyy/aaa|yyy/zzz|zzz'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'UU aaa|UU xxx/aaa|AA xxx/zzz|UU yyy/aaa|AA yyy/zzz|AA zzz'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

printf 'fff0\n' >aaa
printf 'fff1\n' >xxx/aaa
printf 'fff2\n' >yyy/aaa
printf 'xxx0\n' >zzz
printf 'xxx1\n' >xxx/zzz
printf 'xxx2\n' >yyy/zzz
git add aaa xxx/aaa yyy/aaa zzz xxx/zzz yyy/zzz
cd ./xxx
git unstash --continue
cd ..
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|xxx/aaa|xxx/zzz|yyy/aaa|yyy/zzz|zzz'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'MM aaa|MM xxx/aaa| M xxx/zzz|MM yyy/aaa| M yyy/zzz| M zzz'
test "$(git show :aaa)" = 'eee0'
test "$(git show :xxx/aaa)" = 'eee1'
test "$(git show :yyy/aaa)" = 'eee2'
test "$(cat aaa)" = 'fff0'
test "$(cat xxx/aaa)" = 'fff1'
test "$(cat yyy/aaa)" = 'fff2'
test "$(git show :zzz)" = 'yyy0'
test "$(git show :xxx/zzz)" = 'yyy1'
test "$(git show :yyy/zzz)" = 'yyy2'
test "$(cat zzz)" = 'xxx0'
test "$(cat xxx/zzz)" = 'xxx1'
test "$(cat yyy/zzz)" = 'xxx2'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 3
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'master'
