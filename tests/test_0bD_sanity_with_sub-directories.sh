set -e

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

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
cd ./xxx
git stash pop --index
cd ..
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|xxx/aaa|yyy/aaa'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'MM aaa|MM xxx/aaa|MM yyy/aaa|?? xxx/zzz|?? yyy/zzz|?? zzz'
test "$(git show :aaa)" = 'bbb0'
test "$(git show :xxx/aaa)" = 'bbb1'
test "$(git show :yyy/aaa)" = 'bbb2'
test "$(cat aaa)" = 'ccc0'
test "$(cat xxx/aaa)" = 'ccc1'
test "$(cat yyy/aaa)" = 'ccc2'
test "$(cat zzz)" = 'zzz0'
test "$(cat xxx/zzz)" = 'zzz1'
test "$(cat yyy/zzz)" = 'zzz2'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'HEAD'
