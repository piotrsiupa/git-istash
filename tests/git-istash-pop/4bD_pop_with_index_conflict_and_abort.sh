. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 2 capture_outputs git istash pop
assert_conflict_message git istash pop
assert_files '
UU aaa		ddd|bbb
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'pop'
assert_rebase y

assert_exit_code 0 git istash pop --abort
assert_files '
   aaa		ddd
!! ignored	ignored
'
assert_stash_count 1
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n
