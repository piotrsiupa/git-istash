exit 0  #TODO the test is disabled because `git stash` has a bug(?) and doesn't create the stash correctly in this case

. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >bbb
git add bbb
rm bbb
git stash push

git switch --orphan ooo

assert_exit_code 0 git istash pop
assert_files '
AD bbb			bbb
!! ignored	ignored
'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
