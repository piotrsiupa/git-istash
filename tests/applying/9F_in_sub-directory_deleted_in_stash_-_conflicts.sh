. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_CONTINUE

__test_section__ 'Prepare repository'
mkdir 'aaa'
printf 'foo\n' >aaa/bbb
printf 'foo\n' >ccc
git add aaa/bbb ccc
git commit -m 'Added aaa/bbb & ccc'

__test_section__ 'Create stash'
rm -r aaa
printf 'bar\n' >ccc
git stash push

__test_section__ 'Create conflict'
printf 'baz\n' >ccc
git commit -am 'Changed ccc'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
assert_exit_code 2 capture_outputs git istash "$APPLY_OPERATION"
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
D  aaa/bbb
UU ccc		baz|bar
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash"
printf 'qux\n' >ccc
git add ccc
assert_exit_code 0 git istash "$APPLY_OPERATION" "$CONTINUE_FLAG"
assert_files_HT '
 D aaa/bbb	foo
 M ccc		qux		baz
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 3
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
