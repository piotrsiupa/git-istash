. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git add aaa
git stash push

git switch --orphan ooo

assert_exit_code 0 git istash apply
assert_all_files 'aaa|ignored'
assert_status 'A  aaa'
assert_file_contents aaa 'bbb' 'bbb'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
