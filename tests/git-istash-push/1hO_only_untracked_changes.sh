. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git switch --orphan ooo

printf 'ddd\n' >ddd
assert_exit_code 0 git istash push -u
assert_files '
!! ignored	ignored
'
assert_stash 0 'ooo' '' '
?? ddd		ddd
'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_rebase n

git switch master

assert_exit_code 0 git stash pop --index
assert_files '
   aaa		aaa
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
