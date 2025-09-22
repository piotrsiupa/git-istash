. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_CONTINUE

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'ddd\n' >bbb
printf 'eee\n' >ccc
git stash push -u

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory & create conflict'
printf 'fff\n' >aaa
git add aaa
printf 'ggg\n' >aaa
printf 'hhh\n' >bbb
printf 'iii\n' >ccc

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
assert_exit_code 2 git istash "$APPLY_OPERATION"
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU aaa		fff|bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (0)"
printf 'jjj\n' >aaa
git add aaa
assert_exit_code 2 git istash "$APPLY_OPERATION" "$CONTINUE_FLAG"
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU aaa		jjj|ggg
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (1)"
printf 'kkk\n' >aaa
git add aaa
assert_exit_code 2 git istash "$APPLY_OPERATION" "$CONTINUE_FLAG"
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU aaa		kkk|ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (2)"
printf 'lll\n' >aaa
git add aaa
assert_exit_code 2 git istash "$APPLY_OPERATION" "$CONTINUE_FLAG"
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
   aaa		lll
AA bbb		hhh|ddd
AA ccc		iii|eee
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (3)"
printf 'mmm\n' >bbb
printf 'nnn\n' >ccc
git add bbb ccc
assert_exit_code 0 git istash "$APPLY_OPERATION" "$CONTINUE_FLAG"
assert_files_HT '
MM aaa		lll	jjj
?? bbb		mmm
?? ccc		nnn
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
