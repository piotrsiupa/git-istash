. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the stash'
assert_branch_count 1

git switch --orphan ooo

printf 'xxx\n' >aaa
git add aaa
assert_exit_code 1 git istash-pop 1
assert_status 'A  aaa'
assert_file_contents aaa 'xxx' 'xxx'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
