. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

__test_section__ 'Prepare repository'
git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git stash push

__test_section__ 'Create conflict'
git switch -c branch1
git commit --allow-empty -m 'Changed nothing'

git switch branch0
SWITCH_HEAD_TYPE

__test_section__ 'Merge branch'
git merge branch1 --no-ff --no-commit
assert_files_H '
   aaa		aaa
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 2
assert_data_files 'none'
assert_rebase n

__test_section__ 'Apply stash'
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 1 git istash apply
assert_files_H '
   aaa		aaa
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 2
assert_head_hash_H "$correct_head_hash"
assert_data_files 'none'
assert_rebase n
