set -e

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'bbb\n' >aaa
git stash create 'earlier stash entry'
git reset --hard

printf 'ccc\n' >aaa
later_stash_hash="$(git stash create 'later stash entry')"
git reset --hard
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0

correct_head_hash="$(git rev-parse HEAD)"
git unstash "$later_stash_hash"
test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = 'aaa'
test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = ' M aaa'
test "$(git show :aaa)" = 'aaa'
test "$(cat aaa)" = 'ccc'
test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq 0
test "$(git rev-list --count HEAD)" -eq 2
test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq 1
test "$(git rev-parse HEAD)" = "$correct_head_hash"
test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = 'master'
