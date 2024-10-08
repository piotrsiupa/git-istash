. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git stash push -u -m 'earlier stash entry'
git branch earlier stash
git stash drop
git reset --hard

printf 'ccc\n' >aaa
git stash push -u -m 'later stash entry'
git branch later stash
git stash drop
git reset --hard
assert_stash_count 0

git switch --orphan ooo

assert_exit_code 0 git istash apply later
assert_files '
?? aaa		ccc
!! ignored	ignored
'
assert_stash_count 0
assert_branch_count 3
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
