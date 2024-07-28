. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch --orphan ooo

assert_exit_code 2 capture_outputs git istash pop
assert_conflict_message git istash pop
assert_files '
DU aaa
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'pop'
assert_rebase y

correct_head_hash2="$(git rev-parse HEAD)"
printf 'eee\n' >aaa
git add aaa
mv .git/ISTASH_TARGET .git/ISTASH_TARGET~
touch .git/ISTASH_TARGET
assert_exit_code 1 git istash pop --continue
assert_files '
A  aaa		eee
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 2
assert_head_hash "$correct_head_hash2"
assert_rebase y

mv .git/ISTASH_TARGET~ .git/ISTASH_TARGET
assert_exit_code 0 git istash pop --continue
assert_files '
?? aaa		eee
!! ignored	ignored
'
assert_stash_count 0
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
