. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git rm aaa
printf 'bbb\n' >aaa
git stash push -u

git switch --detach HEAD

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 0 git istash pop
assert_files '
D  aaa
?? aaa		bbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n
