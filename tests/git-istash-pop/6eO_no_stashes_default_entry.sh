. "$(dirname "$0")/../commons.sh" 1>/dev/null

git switch --orphan ooo

assert_exit_code 1 git istash pop stash
assert_files '
!! ignored	ignored
'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
assert_exit_code 1 git istash pop stash
assert_files '
AM aaa		eee	ddd
!! ignored	ignored
'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
