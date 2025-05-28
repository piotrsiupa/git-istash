. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP
if IS_APPLY
then
	skip_silently  # this test is "pop" specific
fi

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git stash push

__test_section__ 'Create conflict'
printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 2 capture_outputs git istash "$OPERATION"
assert_conflict_message
assert_files_H '
UU aaa		ddd|bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
DU aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_data_files "$OPERATION"
assert_rebase y
assert_dotgit_contents_for "$OPERATION"

__test_section__ "Continue $OPERATION stash (0)"
correct_head_hash2="$(get_head_hash_H)"
printf 'eee\n' >aaa
git add aaa
mv .git/ISTASH_STASH .git/ISTASH_STASH~
assert_exit_code 1 git istash "$OPERATION" --continue
assert_files_H '
M  aaa		eee
!! ignored0	ignored0
!! ignored1	ignored1
' '
A  aaa		eee
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_head_hash_H "$correct_head_hash2"
assert_rebase y
assert_dotgit_contents 'ISTASH_STASH~' 'ISTASH_TARGET'

__test_section__ "Continue $OPERATION stash (1)"
mv .git/ISTASH_STASH~ .git/ISTASH_STASH
assert_exit_code 0 git istash "$OPERATION" --continue
assert_files_H '
 M aaa		eee	ddd
!! ignored0	ignored0
!! ignored1	ignored1
' '
?? aaa		eee
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
