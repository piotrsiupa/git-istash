. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the stash'

git switch --orphan ooo

printf 'xxx\n' >xxx
git add xxx
assert_exit_code 1 git istash apply 1
assert_status 'A  xxx'
assert_file_contents xxx 'xxx' 'xxx'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
