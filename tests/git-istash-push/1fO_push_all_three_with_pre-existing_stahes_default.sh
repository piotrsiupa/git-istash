. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
printf 'xxx\n' >aaa
git stash push -m 'pre-existing stash 0'
printf 'yyy\n' >aaa
git add aaa
printf 'zzz\n' >aaa
git stash push -m 'pre-existing stash 1'
git reset --hard HEAD~

git switch --orphan ooo

correct_pre_stash_hash_0="$(git rev-parse 'stash@{1}')"
correct_pre_stash_hash_1="$(git rev-parse 'stash@{0}')"
printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'ddd\n' >ddd
assert_exit_code 0 git istash push --message='some fancy name'
assert_files '
?? ddd		ddd
!! ignored	ignored
'
assert_stash 0 'ooo' 'some fancy name' '
AM aaa		ccc	bbb
'
assert_stash_base 0 '' 'ooo'
assert_stash_count 3
assert_branch_count 1
assert_stash_hash 2 "$correct_pre_stash_hash_0"
assert_stash_hash 1 "$correct_pre_stash_hash_1"
assert_head_name '~ooo'
assert_rebase n

git switch master

assert_exit_code 0 git stash pop --index
assert_files '
AM aaa		ccc	bbb
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 2
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
