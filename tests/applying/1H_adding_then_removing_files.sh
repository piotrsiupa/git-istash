. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
rm aaa
git istash push  # Normal "git stash" doesn't allow creation of such stash so "git istash" has to be used instead. (This is a special case in "git stash" for some weird reason.)

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash "$OPERATION"
assert_files_H '
AD aaa		aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_O 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
