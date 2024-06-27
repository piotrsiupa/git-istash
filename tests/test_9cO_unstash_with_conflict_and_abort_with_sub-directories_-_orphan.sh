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

git switch --orphan ooo

mkdir xxx
cd ./xxx
if run_and_capture git istash ; then exit 1 ; fi
cd ..
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git istash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git istash", run "git istash --abort".'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'DU aaa|DU xxx/aaa|DU yyy/aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2

printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd ./xxx
git istash --abort
cd ..
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test ! -d xxx
test ! -d yyy
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
