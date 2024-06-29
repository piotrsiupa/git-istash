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

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
cd ./xxx
if run_and_capture git istash ; then exit 1 ; fi
cd ..
text="$(printf '%s' "$stderr" | tail -n4)"
test "$text" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git istash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git istash", run "git istash --abort".'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'UU aaa|UU xxx/aaa|UU yyy/aaa'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1

printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd ./xxx
git istash --abort
cd ..
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|xxx/aaa|xxx/zzz|yyy/aaa|yyy/zzz|zzz'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git show :aaa)" = 'ddd0'
test "$(git show :xxx/aaa)" = 'ddd1'
test "$(git show :yyy/aaa)" = 'ddd2'
test "$(cat aaa)" = 'ddd0'
test "$(cat xxx/aaa)" = 'ddd1'
test "$(cat yyy/aaa)" = 'ddd2'
test "$(git show :zzz)" = 'yyy0'
test "$(git show :xxx/zzz)" = 'yyy1'
test "$(git show :yyy/zzz)" = 'yyy2'
test "$(cat zzz)" = 'yyy0'
test "$(cat xxx/zzz)" = 'yyy1'
test "$(cat yyy/zzz)" = 'yyy2'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 1
test "$(git rev-list --count HEAD)" -eq 3
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'HEAD'
