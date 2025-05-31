. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
git stash push

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
assert_exit_code 2 capture_outputs git istash "$APPLY_OPERATION"
assert_conflict_message
assert_files_HT '
DU aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count 2
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash"
printf 'ccc\n' >aaa
git add aaa
printf 'zzz\n' >zzz
git add zzz
git commit --amend --no-edit -- zzz
assert_exit_code 1 git istash "$APPLY_OPERATION" --continue
assert_file_contents ignored0 'ignored0'
assert_file_contents ignored1 'ignored1'
assert_branch_metadata_HT
assert_dotgit_contents_for "$APPLY_OPERATION"
