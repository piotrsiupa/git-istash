. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git switch --orphan ooo

printf 'ddd\n' >ddd
assert_exit_code 0 git istash push -k
assert_files '
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
assert_rebase n
