. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git rm aaa
printf 'bbb\n' >aaa
git stash push -u

git switch --orphan ooo

assert_exit_code 0 git istash pop
assert_files '
?? aaa		bbb
!! ignored	ignored
'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
