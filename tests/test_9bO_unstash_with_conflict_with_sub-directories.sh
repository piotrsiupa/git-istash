. "$(dirname "$0")/commons.sh" 1>/dev/null

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

git switch --orphan ooo

mkdir xxx
cd ./xxx
if run_and_capture git unstash ; then exit 1 ; fi
cd ..
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'DU aaa|DU xxx/aaa|DU yyy/aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2

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
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|xxx/aaa|yyy/aaa'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'UU aaa|UU xxx/aaa|A  xxx/zzz|UU yyy/aaa|A  yyy/zzz|A  zzz'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2

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
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'AM aaa|AM xxx/aaa|AM yyy/aaa|?? xxx/zzz|?? yyy/zzz|?? zzz'
test "$(git show :aaa)" = 'eee0'
test "$(git show :xxx/aaa)" = 'eee1'
test "$(git show :yyy/aaa)" = 'eee2'
test "$(cat aaa)" = 'fff0'
test "$(cat xxx/aaa)" = 'fff1'
test "$(cat yyy/aaa)" = 'fff2'
test "$(cat zzz)" = 'xxx0'
test "$(cat xxx/zzz)" = 'xxx1'
test "$(cat yyy/zzz)" = 'xxx2'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
