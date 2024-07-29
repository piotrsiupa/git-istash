. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'zzz\n' >zzz
git stash push -u

printf 'ddd\n' >aaa
printf 'yyy\n' >zzz
git add aaa zzz
git commit -m 'Changed aaa & added zzz'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 2 capture_outputs git istash pop
assert_conflict_message git istash pop
assert_files '
UU aaa		ddd|bbb
   zzz		yyy
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'pop'
assert_rebase y

printf 'eee\n' >aaa
git add aaa
assert_exit_code 2 capture_outputs git istash pop --continue
assert_conflict_message git istash pop --continue
assert_files '
UU aaa		eee|ccc
AA zzz		yyy|zzz
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'pop'
assert_rebase y

printf 'fff\n' >aaa
printf 'xxx\n' >zzz
git add aaa zzz
assert_exit_code 0 git istash pop --continue
assert_files '
MM aaa		fff	eee
 M zzz		xxx	yyy
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n
