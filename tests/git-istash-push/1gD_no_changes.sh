. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git switch -d HEAD

printf 'ddd\n' >ddd
correct_head_hash="$(git rev-parse 'HEAD')"
assert_exit_code 0 git istash push -m 'description'
assert_files '
   aaa		aaa
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_rebase n
