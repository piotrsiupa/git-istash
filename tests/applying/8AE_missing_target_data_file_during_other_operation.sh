. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

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

__test_section__ "$CAP_OTHER_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
#shellcheck disable=SC2086
assert_exit_code 2 capture_outputs git istash $OTHER_APPLY_OPERATION
assert_conflict_message
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
assert_branch_count_HT 1
assert_data_files "$OTHER_APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$OTHER_APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (0)"
correct_head_hash2="$(get_head_hash_HT)"
printf 'ddd\n' >aaa
git add aaa
mv .git/ISTASH_TARGET .git/ISTASH_TARGET~
assert_exit_code 1 git istash "$APPLY_OPERATION" --continue
assert_files_HT '
M  aaa		ddd
!! ignored0	ignored0
!! ignored1	ignored1
' '
A  aaa		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_head_hash_HT "$correct_head_hash2"
assert_rebase y
if IS_APPLY
then
	assert_dotgit_contents 'ISTASH_STASH' 'ISTASH_TARGET~'
else
	assert_dotgit_contents 'ISTASH_TARGET~'
fi

__test_section__ "Continue $OTHER_APPLY_OPERATION stash (1)"
mv .git/ISTASH_TARGET~ .git/ISTASH_TARGET
#shellcheck disable=SC2086
assert_exit_code 0 git istash $OTHER_APPLY_OPERATION --continue
assert_files_HT '
 M aaa		ddd	ccc
!! ignored0	ignored0
!! ignored1	ignored1
' '
?? aaa		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
if IS_APPLY
then
	assert_stash_count 0
else
	assert_stash_count 1
fi
assert_log_length_HT 3
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
