. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push

__test_section__ 'Create conflict'
printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash "$OPERATION"
assert_conflict_message git istash "$OPERATION"
assert_files_H '
UU aaa		ddd|bbb
!! ignored	ignored
' '
DU aaa		bbb
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files "$OPERATION"
assert_rebase y

__test_section__ "Continue $OPERATION stash (0)"
printf 'eee\n' >aaa
assert_exit_code 2 capture_outputs git istash "$OPERATION" --continue
assert_conflict_message git istash "$OPERATION"
assert_files_H '
UU aaa		eee
!! ignored	ignored
' '
DU aaa		eee
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files "$OPERATION"
assert_rebase y

__test_section__ "Continue $OPERATION stash (1)"
git add aaa
assert_exit_code 2 capture_outputs git istash "$OPERATION" --continue
assert_conflict_message git istash "$OPERATION" --continue
assert_files_H '
UU aaa		eee|ccc
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files "$OPERATION"
assert_rebase y

__test_section__ "Continue $OPERATION stash (2)"
printf 'fff\n' >aaa
assert_exit_code 2 capture_outputs git istash "$OPERATION" --continue
assert_conflict_message git istash "$OPERATION" --continue
assert_files_H '
UU aaa		fff
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files "$OPERATION"
assert_rebase y

__test_section__ "Continue $OPERATION stash (3)"
git add aaa
assert_exit_code 0 git istash "$OPERATION" --continue
assert_files_H '
MM aaa		fff	eee
!! ignored	ignored
' '
AM aaa		fff	eee
!! ignored	ignored
'
assert_stash_count_O 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
