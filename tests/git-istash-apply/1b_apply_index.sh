. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
git stash push

SWITCH_HEAD_TYPE

__test_section__ 'Apply stash'
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash apply
assert_files_H '
M  aaa		bbb
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
