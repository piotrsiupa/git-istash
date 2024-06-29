. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch --orphan ooo

assert_failure capture_outputs git unstash
assert_conflict_message git unstash
assert_status 'DU aaa'
assert_stash_count 1
assert_branch_count 2

assert_success git unstash --abort
assert_status ''
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
