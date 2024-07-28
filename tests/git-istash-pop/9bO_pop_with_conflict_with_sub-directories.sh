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
assert_exit_code 2 capture_outputs git istash pop
cd ..
assert_conflict_message git istash pop
assert_files '
DU aaa
DU xxx/aaa
DU yyy/aaa
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'pop'
assert_rebase y

printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
assert_exit_code 2 capture_outputs git istash pop --continue
cd ..
assert_conflict_message git istash pop --continue
assert_files '
UU aaa
UU xxx/aaa
UU yyy/aaa
A  zzz		zzz0
A  xxx/zzz	zzz1
A  yyy/zzz	zzz2
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'pop'
assert_rebase y

printf 'fff0\n' >aaa
printf 'fff1\n' >xxx/aaa
printf 'fff2\n' >yyy/aaa
printf 'xxx0\n' >zzz
printf 'xxx1\n' >xxx/zzz
printf 'xxx2\n' >yyy/zzz
git add aaa xxx/aaa yyy/aaa zzz xxx/zzz yyy/zzz
cd xxx
assert_exit_code 0 git istash pop --continue
cd ..
assert_files '
AM aaa		fff0	eee0
AM xxx/aaa	fff1	eee1
AM yyy/aaa	fff2	eee2
?? zzz		xxx0
?? xxx/zzz	xxx1
?? yyy/zzz	xxx2
!! ignored	ignored
'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
