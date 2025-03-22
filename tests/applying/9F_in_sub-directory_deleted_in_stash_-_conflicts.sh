. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_POP

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

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash "$OPERATION"
assert_conflict_message
assert_files_H '
D  aaa/bbb
UU ccc		baz|bar
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files "$OPERATION"
assert_rebase y
assert_dotgit_contents_for "$OPERATION"

__test_section__ "Continue $OPERATION stash"
printf 'qux\n' >ccc
git add ccc
assert_exit_code 0 git istash "$OPERATION" --continue
assert_files_H '
 D aaa/bbb	foo
 M ccc		qux		baz
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_O 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
