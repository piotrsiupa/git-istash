. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'added aaa'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the stash'
assert_branch_count 1

git switch --orphan ooo

printf 'xxx\n' >xxx
git add -N xxx
assert_exit_code 1 git istash apply 1
assert_files '
 A xxx		xxx
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
