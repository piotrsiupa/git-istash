. "$(dirname "$0")/../commons.sh" 1>/dev/null

mkdir xxx yyy
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
assert_exit_code 0 git istash apply
cd ..
assert_files '
AM aaa		ccc0	bbb0
AM xxx/aaa	ccc1	bbb1
AM yyy/aaa	ccc2	bbb2
?? zzz		zzz0
?? xxx/zzz	zzz1
?? yyy/zzz	zzz2
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
