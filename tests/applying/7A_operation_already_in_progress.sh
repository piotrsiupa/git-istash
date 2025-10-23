. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_CONTINUE

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git stash push

__test_section__ 'Create conflict'
printf 'ccc\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha_0="$(get_head_sha_HT)"
assert_exit_code 2 git istash "$APPLY_OPERATION"
assert_outputs__apply__conflict_HT "$APPLY_OPERATION" '
UU aaa
' '
DU aaa
'
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU aaa		ccc|bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
DU aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "$CAP_APPLY_OPERATION stash again"
correct_head_sha_1="$(get_head_sha_HT)"
assert_exit_code 1 git istash "$APPLY_OPERATION"
assert_outputs__apply__operation_in_progress "istash $APPLY_OPERATION"
assert_files_HT '
UU aaa		ccc|bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
DU aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_head_sha_HT "$correct_head_sha_1"
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue the first $APPLY_OPERATION stash"
printf 'ddd\n' >aaa
git add aaa
stash_sha="$(git rev-parse stash)"
assert_exit_code 0 git istash "$APPLY_OPERATION" "$CONTINUE_FLAG"
assert_outputs__apply__success "$APPLY_OPERATION" 0 "$stash_sha"
assert_files_HT '
 M aaa		ddd	ccc
!! ignored0	ignored0
!! ignored1	ignored1
' '
 A aaa		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_head_sha_HT "$correct_head_sha_0"
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
