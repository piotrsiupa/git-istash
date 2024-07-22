. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 2 capture_outputs git istash apply
assert_conflict_message git istash apply
assert_tracked_files 'aaa'
assert_status 'UU aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'apply'
assert_rebase y

correct_head_hash2="$(git rev-parse HEAD)"
printf 'eee\n' >aaa
git add aaa
mv .git/ISTASH_TARGET .git/ISTASH_TARGET~
printf 'fa4e08a58\n' >.git/ISTASH_TARGET
assert_exit_code 1 git istash apply --continue
assert_tracked_files 'aaa'
assert_status 'M  aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 1
assert_head_hash "$correct_head_hash2"
assert_data_files 'apply'
assert_rebase y

mv .git/ISTASH_TARGET~ .git/ISTASH_TARGET
assert_exit_code 0 git istash apply --continue
assert_tracked_files 'aaa'
assert_status ' M aaa'
assert_file_contents aaa 'eee' 'ddd'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n
