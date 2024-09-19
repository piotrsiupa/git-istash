. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP
if IS_POP
then
	skip_silently # "pop" doesn't support branch names, which is checked in an ealier test
fi

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
git stash push -m 'the only stash'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash (without changes)"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 1 git istash "$OPERATION" HEAD^
assert_files_H '
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_data_files 'none'
assert_rebase n

__test_section__ "$CAP_OPERATION stash (with changes)"
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
assert_exit_code 1 git istash "$OPERATION" HEAD^
assert_files_H '
AM aaa		bbb	aaa
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
