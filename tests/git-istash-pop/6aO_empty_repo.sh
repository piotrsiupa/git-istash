. "$(dirname "$0")/../commons.sh" 1>/dev/null

rm -rf .git
git init
printf 'ignored\n' >>.git/info/exclude

git switch --orphan ooo

assert_exit_code 1 git istash pop
assert_status ''
assert_file_contents ignored 'ignored'
assert_stash_count 0
assert_head_name '~ooo'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
assert_exit_code 1 git istash pop
assert_status 'AM aaa'
assert_file_contents aaa 'eee' 'ddd'
assert_file_contents ignored 'ignored'
assert_stash_count 0
assert_branch_count 0
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
