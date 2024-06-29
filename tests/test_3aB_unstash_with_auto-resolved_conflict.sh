set -e

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'bbb\n' >aaa
git commit -am 'Changed aaa'

correct_head_hash="$(git rev-parse HEAD)"
git istash
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ''
test "$(git show :aaa)" = 'bbb'
test "$(cat aaa)" = 'bbb'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 3
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'master'
