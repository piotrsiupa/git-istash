. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_ABORT

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

__test_section__ 'Dirty the working directory'
printf 'wdf0a\n' >wdf0
git add wdf0
printf 'wdf0b\n' >wdf0
printf 'wdf1a\n' >wdf1

__test_section__ 'Pop stash'
correct_head_sha="$(get_head_sha_HT)"
assert_exit_code 2 git istash pop
assert_outputs__apply__conflict_HT 'pop' '
UU aaa
' '
DU aaa
'
assert_conflict_message 'pop'
assert_files_HT '
UU aaa		ccc|bbb
   wdf0		wdf0b
!! ignored0	ignored0
!! ignored1	ignored1
' '
DU aaa		bbb
   wdf0		wdf0b
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files 'pop'
assert_rebase y
assert_dotgit_contents_for 'pop'

if IS_APPLY
then
	__test_section__ 'Apply stash'
else
	__test_section__ 'Pop stash again'
fi
mv .git/ISTASH_TARGET .git/ISTASH_TARGET~
correct_head_sha2="$(get_head_sha_HT)"
printf 'ddd\n' >aaa
git add aaa
assert_exit_code 1 git istash "$APPLY_OPERATION"
assert_outputs__apply__broken_operation_in_progress "$APPLY_OPERATION" 'pop' 'files ".git/ISTASH_WORKING-DIR" and ".git/ISTASH_STASH"' '".git/ISTASH_TARGET" is'
assert_files_HT '
M  aaa		ddd
   wdf0		wdf0b
!! ignored0	ignored0
!! ignored1	ignored1
' '
A  aaa		ddd
   wdf0		wdf0b
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_head_sha_HT "$correct_head_sha2"
assert_rebase y
assert_dotgit_contents 'ISTASH_STASH' 'ISTASH_TARGET~' 'ISTASH_WORKING-DIR'

__test_section__ 'Abort popping stash'
mv .git/ISTASH_TARGET~ .git/ISTASH_TARGET
assert_exit_code 0 git istash pop "$ABORT_FLAG"
assert_outputs__apply__abort 'pop'
assert_files_HT '
   aaa		ccc
AM wdf0		wdf0b	wdf0a
?? wdf1		wdf1a
!! ignored0	ignored0
!! ignored1	ignored1
' '
AM wdf0		wdf0b	wdf0a
?? wdf1		wdf1a
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 3
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
