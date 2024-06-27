set -e

mkdir xxx yyy
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
git stash pop --index
cd ..
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = 'AM aaa|AM xxx/aaa|AM yyy/aaa|?? xxx/zzz|?? yyy/zzz|?? zzz'
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
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
if git rev-parse HEAD ; then exit 1 ; fi
test "$(git branch --show-current)" = 'ooo'
