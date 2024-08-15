. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git switch --orphan ooo

printf 'ddd\n' >ddd
assert_exit_code 1 git istash push --include-untracked -k -m 'my stash'  #TODO the error code is a bug in Git
return 0  #TODO remove after the bug in Git is fixed
assert_files '
!! ignored	ignored
'
assert_stash 0 'ooo' 'my stash' '
?? ddd		ddd
'
assert_stash_base 0 '' 'ooo'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_rebase n

git reset --hard
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
