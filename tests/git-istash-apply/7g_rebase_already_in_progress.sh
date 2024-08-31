. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch -c branch1
printf 'xxx\n' >xxx
git add xxx
git commit -m 'Changed xxx'

SWITCH_HEAD_TYPE

git rebase branch0 --exec='return 1' || true
assert_files_H '
   aaa		aaa
   xxx		xxx
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 2
assert_data_files 'none'
assert_rebase y

correct_head_hash="$(get_head_hash_H)"
assert_exit_code 1 git istash apply
assert_files_H '
   aaa		aaa
   xxx		xxx
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count 2
assert_head_hash_H "$correct_head_hash"
assert_data_files 'none'
assert_rebase y
