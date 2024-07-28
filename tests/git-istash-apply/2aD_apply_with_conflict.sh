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
assert_files '
UU aaa
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'apply'
assert_rebase y

printf 'eee\n' >aaa
git add aaa
assert_exit_code 0 git istash apply --continue
assert_files '
 M aaa		eee	ddd
!! ignored	ignored
'
assert_stash_count 1
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n
