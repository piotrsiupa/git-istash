set -e

. "$(dirname "$0")/utils.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
if run_and_capture git istash ; then exit 1 ; fi
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git istash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git istash", run "git istash --abort".'
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'UU aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

correct_head_hash2="$(git rev-parse HEAD)"
printf 'eee\n' >aaa
git add aaa
if git istash --abort 0 ; then exit 1 ; fi
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'M  aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash2"

git istash --abort
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git show :aaa)" = 'ddd'
test "$(cat aaa)" = 'ddd'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-list --count HEAD)" -eq 3
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'HEAD'
