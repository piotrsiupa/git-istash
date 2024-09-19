. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_POP

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'zzz\n' >zzz
git stash push -u

__test_section__ 'Create conflict'
printf 'ddd\n' >aaa
printf 'yyy\n' >zzz
git add aaa zzz
git commit -m 'Changed aaa & added zzz'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash "$OPERATION"
assert_conflict_message
assert_files_H '
UU aaa		ddd|bbb
   zzz		yyy
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files "$OPERATION"
assert_rebase y

__test_section__ "Continue $OPERATION stash"
printf 'eee\n' >aaa
git add aaa
assert_exit_code 2 capture_outputs git istash "$OPERATION" --continue
assert_conflict_message
assert_files_H '
UU aaa		eee|ccc
AA zzz		yyy|zzz
!! ignored	ignored
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files "$OPERATION"
assert_rebase y

__test_section__ "Abort $OPERATION stash"
assert_exit_code 0 git istash "$OPERATION" --abort
assert_files_H '
   aaa		ddd
   zzz		yyy
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
