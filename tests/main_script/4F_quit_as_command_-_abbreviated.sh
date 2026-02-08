. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_OPTION true 'QUIT_COMMAND' 'option' 'QUIT: q && qui && qu'
PARAMETRIZE_COLOR

__end_of_initialization__

prepare_repository

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
git stash push

__test_section__ 'Create conflict'
printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $COLOR_FLAGS
assert_outputs__apply__conflict_HT "$APPLY_OPERATION" '
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
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Quit (implied) $APPLY_OPERATION stash"
#shellcheck disable=SC2086
assert_exit_code 1 git istash "$QUIT_COMMAND" $COLOR_FLAGS
assert_outputs__main_script__no_such_command "$QUIT_COMMAND"
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
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"
