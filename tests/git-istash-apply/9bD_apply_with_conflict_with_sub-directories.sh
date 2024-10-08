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
assert_exit_code 2 capture_outputs git istash apply
cd ..
assert_conflict_message git istash apply
assert_files '
UU aaa		ddd0|bbb0
UU xxx/aaa	ddd1|bbb1
UU yyy/aaa	ddd2|bbb2
   zzz		yyy0
   xxx/zzz	yyy1
   yyy/zzz	yyy2
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'apply'
assert_rebase y

printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
assert_exit_code 2 capture_outputs git istash apply --continue
cd ..
assert_conflict_message git istash apply --continue
assert_files '
UU aaa		eee0|ccc0
UU xxx/aaa	eee1|ccc1
UU yyy/aaa	eee2|ccc2
AA zzz		yyy0|zzz0
AA xxx/zzz	yyy1|zzz1
AA yyy/zzz	yyy2|zzz2
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'apply'
assert_rebase y

printf 'fff0\n' >aaa
printf 'fff1\n' >xxx/aaa
printf 'fff2\n' >yyy/aaa
printf 'xxx0\n' >zzz
printf 'xxx1\n' >xxx/zzz
printf 'xxx2\n' >yyy/zzz
git add aaa xxx/aaa yyy/aaa zzz xxx/zzz yyy/zzz
cd xxx
assert_exit_code 0 git istash apply --continue
cd ..
assert_files '
MM aaa		fff0	eee0
MM xxx/aaa	fff1	eee1
MM yyy/aaa	fff2	eee2
 M zzz		xxx0	yyy0
 M xxx/zzz	xxx1	yyy1
 M yyy/zzz	xxx2	yyy2
!! ignored	ignored
'
assert_stash_count 1
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_data_files 'none'
assert_rebase n
