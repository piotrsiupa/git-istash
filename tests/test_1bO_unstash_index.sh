. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'bbb\n' >aaa
git add aaa
git stash push

git switch --orphan ooo

git unstash
assert_status 'A  aaa'
assert_file_contents aaa 'bbb' 'bbb'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
