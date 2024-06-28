. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'zzz\n' >zzz
git stash push -u

printf 'bbb\n' >aaa
printf 'zzz\n' >zzz
git add aaa zzz
git commit -m 'Changed aaa & added zzz'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
git unstash
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa|zzz'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ' M aaa'
test "$(git show :aaa)" = 'bbb'
test "$(cat aaa)" = 'ccc'
test "$(git show :zzz)" = 'zzz'
test "$(cat zzz)" = 'zzz'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 3
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'HEAD'
