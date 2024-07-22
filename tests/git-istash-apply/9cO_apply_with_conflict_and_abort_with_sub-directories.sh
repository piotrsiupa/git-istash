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

git switch --orphan ooo

mkdir xxx
cd xxx
assert_exit_code 2 capture_outputs git istash apply
cd ..
assert_conflict_message git istash apply
assert_status 'DU aaa|DU xxx/aaa|DU yyy/aaa'
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'apply'
assert_rebase y

printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
assert_exit_code 0 git istash apply --abort
cd ..
assert_status ''
assert_file_contents ignored 'ignored'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
