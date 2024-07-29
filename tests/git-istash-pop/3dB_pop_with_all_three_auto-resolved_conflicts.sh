. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'zzz\n' >zzz
git stash push -u

printf 'bbb\n' >aaa
printf 'zzz\n' >zzz
git add aaa zzz
git commit -m 'Changed aaa & added zzz'

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 0 git istash pop
assert_files '
 M aaa		ccc	bbb
   zzz		zzz
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
