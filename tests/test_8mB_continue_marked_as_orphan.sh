. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

assert_failure capture_outputs git istash
assert_conflict_message git istash
assert_tracked_files 'aaa'
assert_status 'UU aaa'
assert_stash_count 1
assert_branch_count 1

printf 'eee\n' >aaa
git add aaa
mv '.git/istash' '.git/istash~'
head -n 1 '.git/istash~' >'.git/istash'
{ printf '~' ; tail -n 1 '.git/istash~' ; } >>'.git/istash'
assert_failure git istash --continue
