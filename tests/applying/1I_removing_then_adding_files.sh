. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
git rm aaa
printf 'bbb\n' >aaa
git stash push -u

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash "$OPERATION"
assert_files_H '
D  aaa
?? aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
?? aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_O 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
