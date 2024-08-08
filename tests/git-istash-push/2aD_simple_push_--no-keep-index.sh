. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git switch -d HEAD

printf 'bbb\n' >aaa
correct_head_hash="$(git rev-parse 'HEAD')"
assert_exit_code 0 git istash push --no-keep-index
assert_files '
   aaa		aaa
!! ignored	ignored
'
assert_stash 0 '' '' '
 M aaa		bbb	aaa
'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n

git switch master

assert_exit_code 0 git stash pop --index
assert_files '
 M aaa		bbb	aaa
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
