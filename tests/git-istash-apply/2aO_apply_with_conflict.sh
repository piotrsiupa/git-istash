. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch --orphan ooo

assert_failure capture_outputs git istash-apply
assert_conflict_message git istash-apply
assert_status 'DU aaa'
assert_stash_count 1
assert_branch_count 2

printf 'eee\n' >aaa
git add aaa
assert_success git istash-apply --continue
assert_status '?? aaa'
assert_file_contents aaa 'eee'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
