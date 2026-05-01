. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_CONTINUE
PARAMETRIZE_COLOR
PARAMETRIZE_QUIET
PARAMETRIZE_SUMMARY

__end_of_initialization__

prepare_repository

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
git add ccc
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
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $QUIET_FLAGS $COLOR_FLAGS $SUMMARY_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 0 '
UU aaa
'
assert_files_HT '
UU aaa		fff|bbb
A  ccc		eee
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
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $QUIET_FLAGS $COLOR_FLAGS "$CONTINUE_FLAG" $SUMMARY_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 1 '
UU aaa
'
assert_files_HT '
UU aaa		jjj|ggg
   ccc		eee
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
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $QUIET_FLAGS $COLOR_FLAGS "$CONTINUE_FLAG" $SUMMARY_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 2 '
UU aaa
'
assert_files_HT '
UU aaa		kkk|ccc
   ccc		eee
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
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $QUIET_FLAGS $COLOR_FLAGS "$CONTINUE_FLAG" $SUMMARY_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 3 '
AA ccc
'
assert_files_HT '
   aaa		lll
A  bbb		hhh
AA ccc		eee|iii
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (3)"
printf 'mmm\n' >ccc
git add ccc
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $QUIET_FLAGS $COLOR_FLAGS "$CONTINUE_FLAG" $SUMMARY_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 4 '
AA bbb
'
assert_files_HT '
   aaa		lll
AA bbb		hhh|ddd
   ccc		mmm
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (4)"
printf 'nnn\n' >bbb
git add bbb ccc
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$APPLY_OPERATION" $QUIET_FLAGS $COLOR_FLAGS "$CONTINUE_FLAG" $SUMMARY_FLAGS
assert_outputs__apply__success "$APPLY_OPERATION" '
MM aaa
?M bbb
AM ccc
' 0 "$stash_sha"
assert_files_HT '
MM aaa		lll	jjj
?? bbb		nnn
AM ccc		mmm	eee
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
