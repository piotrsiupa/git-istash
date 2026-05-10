. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION 'pop'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_CONTINUE
PARAMETRIZE_COLOR
PARAMETRIZE_QUIET
PARAMETRIZE_SUMMARY
PARAMETRIZE_HINT 'istashConflicts' 'istashContinueOrAbort'

__end_of_initialization__

prepare_repository

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

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 2 git $ADVICE_FLAGS istash "$APPLY_OPERATION" $SUMMARY_FLAGS $QUIET_FLAGS $COLOR_FLAGS
assert_outputs__apply__conflict_HT "$APPLY_OPERATION" 2 '
UU aaa
' '
DU aaa
'
assert_files_HT '
UU aaa		ddd|bbb
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

__test_section__ "Continue $APPLY_OPERATION stash (0)"
correct_head_sha2="$(get_head_sha_HT)"
printf 'eee\n' >aaa
git add aaa
mv .git/ISTASH_STASH .git/ISTASH_STASH~
#shellcheck disable=SC2086
assert_exit_code 1 git $ADVICE_FLAGS istash "$CREATE_OPERATION" $QUIET_FLAGS $COLOR_FLAGS
assert_outputs__operation_in_progress "istash $OTHER_APPLY_OPERATION"
assert_files_HT '
M  aaa		eee
!! ignored0	ignored0
!! ignored1	ignored1
' '
A  aaa		eee
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_head_sha_HT "$correct_head_sha2"
assert_rebase y
assert_dotgit_contents 'ISTASH_STASH~' 'ISTASH_TARGET' 'ISTASH_WORKING-DIR'

__test_section__ "Continue $APPLY_OPERATION stash (1)"
mv .git/ISTASH_STASH~ .git/ISTASH_STASH
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git $ADVICE_FLAGS istash "$APPLY_OPERATION" $SUMMARY_FLAGS $QUIET_FLAGS $COLOR_FLAGS "$CONTINUE_FLAG"
assert_outputs__apply__success_HT "$APPLY_OPERATION" '
 M aaa
' '
 A aaa
' 0 "$stash_sha"
assert_files_HT '
 M aaa		eee	ddd
!! ignored0	ignored0
!! ignored1	ignored1
' '
 A aaa		eee
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_HT 3
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
