. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
git stash push -m 'the only stash'

git switch --orphan ooo

assert_exit_code 1 git istash-apply 'stash^{/second}'
assert_status ''
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'

printf 'ddd\n' >aaa
git add aaa
printf 'eee\n' >aaa
assert_exit_code 1 git istash-apply 'stash^{/second}'
assert_status 'AM aaa'
assert_file_contents aaa 'eee' 'ddd'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
