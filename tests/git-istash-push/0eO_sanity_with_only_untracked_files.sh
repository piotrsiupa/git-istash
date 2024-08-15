. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
assert_files '
   aaa		aaa
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_rebase n

git switch --orphan ooo

printf 'ddd\n' >ddd
if git stash push -u --message 'name'
then
	# This doesn't work in normal `git stash`
	exit 1
fi
