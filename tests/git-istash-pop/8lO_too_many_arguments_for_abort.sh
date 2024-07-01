. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch --orphan ooo

assert_failure capture_outputs git istash-pop
assert_conflict_message git istash-pop
assert_status 'DU aaa'
assert_stash_count 1
assert_branch_count 2

correct_head_hash2="$(git rev-parse HEAD)"
printf 'eee\n' >aaa
git add aaa
assert_failure git istash-pop --abort 0
assert_status 'A  aaa'
assert_stash_count 1
assert_branch_count 2
assert_head_hash "$correct_head_hash2"

assert_success git istash-pop --abort
assert_status ''
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
