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

git switch -d HEAD

correct_head_hash="$(git rev-parse HEAD)"
cd xxx
assert_exit_code 0 git stash push -u
cd ..
assert_all_files 'aaa|ignored|xxx/aaa|yyy/aaa'
assert_tracked_files 'aaa|xxx/aaa|yyy/aaa'
assert_status ''
assert_file_contents aaa 'aaa0' 'aaa0'
assert_file_contents xxx/aaa 'aaa1' 'aaa1'
assert_file_contents yyy/aaa 'aaa2' 'aaa2'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n
