. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 2 capture_outputs git istash pop
assert_conflict_message git istash pop
assert_files '
UU aaa		ddd|bbb
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'pop'
assert_rebase y

correct_head_hash2="$(git rev-parse HEAD)"
printf 'eee\n' >aaa
git add aaa
mv .git/ISTASH_TARGET .git/ISTASH_TARGET~
assert_exit_code 1 git istash apply --continue
assert_files '
M  aaa		eee
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_head_hash "$correct_head_hash2"
assert_rebase y

mv .git/ISTASH_TARGET~ .git/ISTASH_TARGET
assert_exit_code 0 git istash pop --continue
assert_files '
 M aaa		eee	ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
