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

correct_head_hash="$(git rev-parse HEAD)"
cd xxx
assert_exit_code 0 git istash-apply
cd ..
assert_tracked_files 'aaa|xxx/aaa|yyy/aaa'
assert_status 'MM aaa|MM xxx/aaa|MM yyy/aaa|?? xxx/zzz|?? yyy/zzz|?? zzz'
assert_file_contents aaa 'ccc0' 'bbb0'
assert_file_contents xxx/aaa 'ccc1' 'bbb1'
assert_file_contents yyy/aaa 'ccc2' 'bbb2'
assert_file_contents zzz 'zzz0'
assert_file_contents xxx/zzz 'zzz1'
assert_file_contents yyy/zzz 'zzz2'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
