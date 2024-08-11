. "$(dirname "$0")/../commons.sh" 1>/dev/null

git switch --orphan ooo

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'ddd\n' >ddd
assert_exit_code 0 git istash push -u -m 'behold, it'\''s a stash'
assert_files '
!! ignored	ignored
'
assert_stash 0 'ooo' 'behold, it'\''s a stash' '
AM aaa		ccc	bbb
?? ddd		ddd
'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_rebase n

git switch master

assert_exit_code 0 git stash pop --index
assert_files '
AM aaa		ccc	bbb
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
