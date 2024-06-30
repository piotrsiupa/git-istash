. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch --orphan ooo

assert_failure capture_outputs git istash
assert_conflict_message git istash
assert_status 'DU aaa'
assert_stash_count 1
assert_branch_count 2

correct_head_hash2="$(git rev-parse HEAD)"
printf 'eee\n' >aaa
git add aaa
mv ./.git/ISTASH_STASH ./.git/ISTASH_STASH~
printf 'fa4e08a58\n' >./.git/ISTASH_STASH
assert_failure git istash --continue
assert_status 'A  aaa'
assert_stash_count 1
assert_branch_count 2
assert_head_hash "$correct_head_hash2"

mv ./.git/ISTASH_STASH~ ./.git/ISTASH_STASH
assert_success git istash --continue
assert_status '?? aaa'
assert_file_contents aaa 'eee'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
