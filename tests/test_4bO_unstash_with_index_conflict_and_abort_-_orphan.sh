set -e

. "$(dirname "$0")/utils.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
git stash push

git switch --orphan ooo

if run_and_capture git istash ; then exit 1 ; fi
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git istash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git istash", run "git istash --abort".'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'DU aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 2

git istash --abort
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
