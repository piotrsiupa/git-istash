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

printf 'ddd\n' >aaa
printf 'yyy\n' >zzz
git add aaa zzz
git commit -m 'Changed aaa & added zzz'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
if run_and_capture git istash ; then exit 1 ; fi
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git istash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git istash", run "git istash --abort".'
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|zzz'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'UU aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

printf 'eee\n' >aaa
git add aaa
if run_and_capture git istash --continue ; then exit 1 ; fi
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git istash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git istash", run "git istash --abort".'
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|zzz'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'UU aaa|AA zzz'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

git istash --abort
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|zzz'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'ddd'
test "$(git show :zzz)" = 'yyy'
test "$(cat zzz)" = 'yyy'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-list --count HEAD)" -eq 3
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'HEAD'
