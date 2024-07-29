. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git stash push -u -m 'earlier stash entry'
assert_stash_count 1

printf 'ccc\n' >aaa
git stash push -u -m 'later stash entry'
assert_stash_count 2

git switch --orphan ooo

assert_exit_code 0 git istash apply
assert_files '
?? aaa		ccc
!! ignored	ignored
'
assert_stash_count 2
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
