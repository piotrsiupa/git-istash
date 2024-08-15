. "$(dirname "$0")/../commons.sh" 1>/dev/null

git switch --orphan ooo

printf 'bbb\n' >aaa
git add aaa
assert_exit_code 0 git istash push -m'name'
assert_files '
!! ignored	ignored
'
assert_stash 0 'ooo' 'name' '
A  aaa		bbb
'
assert_stash_base 0 '' 'ooo'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_rebase n

git switch master

assert_exit_code 0 git stash pop --index
assert_files '
A  aaa		bbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
