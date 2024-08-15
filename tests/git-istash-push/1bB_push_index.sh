. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
correct_head_hash="$(git rev-parse 'HEAD')"
assert_exit_code 0 git istash push -m 'new-stash'
assert_files '
   aaa		aaa
!! ignored	ignored
'
assert_stash 0 'master' 'new-stash' '
M  aaa		bbb
'
assert_stash_base 0 'HEAD'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n

assert_exit_code 0 git stash pop --index
assert_files '
M  aaa		bbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
