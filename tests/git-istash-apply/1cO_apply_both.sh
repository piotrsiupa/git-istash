. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push

git switch --orphan ooo

git istash-apply
assert_status 'AM aaa'
assert_file_contents aaa 'ccc' 'bbb'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
