exit 0  #TODO the test is disabled because `git stash` has a bug(?) and doesn't create the stash correctly in this case

. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >bbb
git add bbb
rm bbb
git stash push

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 0 git istash apply
assert_files '
   aaa		aaa
AD bbb			bbb
!! ignored	ignored
'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
