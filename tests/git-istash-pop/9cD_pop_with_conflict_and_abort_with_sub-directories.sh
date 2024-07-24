. "$(dirname "$0")/../commons.sh" 1>/dev/null

mkdir xxx yyy
printf 'aaa0\n' >aaa
printf 'aaa1\n' >xxx/aaa
printf 'aaa2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
git commit -m 'Added aaa'

printf 'bbb0\n' >aaa
printf 'bbb1\n' >xxx/aaa
printf 'bbb2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
printf 'ccc0\n' >aaa
printf 'ccc1\n' >xxx/aaa
printf 'ccc2\n' >yyy/aaa
printf 'zzz0\n' >zzz
printf 'zzz1\n' >xxx/zzz
printf 'zzz2\n' >yyy/zzz
git stash push -u

printf 'ddd0\n' >aaa
printf 'ddd1\n' >xxx/aaa
printf 'ddd2\n' >yyy/aaa
printf 'yyy0\n' >zzz
printf 'yyy1\n' >xxx/zzz
printf 'yyy2\n' >yyy/zzz
git add aaa xxx/aaa yyy/aaa zzz xxx/zzz yyy/zzz
git commit -m 'Changed aaa & added zzz'

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
cd xxx
assert_exit_code 2 capture_outputs git istash pop
cd ..
assert_conflict_message git istash pop
assert_all_files 'aaa|ignored|xxx/aaa|xxx/zzz|yyy/aaa|yyy/zzz|zzz'
assert_tracked_files 'aaa|xxx/aaa|xxx/zzz|yyy/aaa|yyy/zzz|zzz'
assert_status 'UU aaa|UU xxx/aaa|UU yyy/aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'pop'
assert_rebase y

printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
assert_exit_code 0 git istash pop --abort
cd ..
assert_all_files 'aaa|ignored|xxx/aaa|xxx/zzz|yyy/aaa|yyy/zzz|zzz'
assert_tracked_files 'aaa|xxx/aaa|xxx/zzz|yyy/aaa|yyy/zzz|zzz'
assert_status ''
assert_file_contents aaa 'ddd0' 'ddd0'
assert_file_contents xxx/aaa 'ddd1' 'ddd1'
assert_file_contents yyy/aaa 'ddd2' 'ddd2'
assert_file_contents zzz 'yyy0' 'yyy0'
assert_file_contents xxx/zzz 'yyy1' 'yyy1'
assert_file_contents yyy/zzz 'yyy2' 'yyy2'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n
