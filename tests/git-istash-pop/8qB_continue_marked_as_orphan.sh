. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

assert_failure capture_outputs git istash-pop
assert_conflict_message git istash-pop
assert_tracked_files 'aaa'
assert_status 'UU aaa'
assert_stash_count 1
assert_branch_count 1

printf 'eee\n' >aaa
git add aaa
mv '.git/ISTASH_TARGET' '.git/ISTASH_TARGET~'
{ printf '~' ; cat '.git/ISTASH_TARGET~' ; } >'.git/ISTASH_TARGET'
assert_failure git istash-pop --continue
