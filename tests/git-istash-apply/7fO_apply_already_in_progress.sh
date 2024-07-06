. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch --orphan ooo

assert_exit_code 2 capture_outputs git istash apply
assert_conflict_message git istash apply
assert_status 'DU aaa'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'apply'
assert_rebase y

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 1 git istash apply
assert_status 'DU aaa'
assert_stash_count 1
assert_branch_count 2
assert_head_hash "$correct_head_hash"
assert_data_files 'apply'
assert_rebase y
