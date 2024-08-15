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

git switch -d HEAD

correct_head_hash="$(git rev-parse 'HEAD')"
printf 'ddd\n' >ddd
assert_exit_code 0 git stash push -u -m 'name'
assert_files '
   aaa		aaa
!! ignored	ignored
'
assert_stash 0 '' 'name' '
   aaa		aaa
?? ddd		ddd
'
assert_stash_base 0 'HEAD'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_rebase n
