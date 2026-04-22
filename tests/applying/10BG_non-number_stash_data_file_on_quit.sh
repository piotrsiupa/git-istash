. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_QUIT
PARAMETRIZE_COLOR

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

__test_section__ 'Dirty the working directory'
printf 'wdf0a\n' >wdf0
git add wdf0
printf 'wdf0b\n' >wdf0
printf 'wdf1a\n' >wdf1

__test_section__ 'Pop stash'
#shellcheck disable=SC2086
assert_exit_code 2 git istash 'pop' $COLOR_FLAGS
assert_outputs__apply__conflict_HT 'pop' 2 '
UU aaa
' '
DU aaa
'
assert_files_HT '
UU aaa		ddd|bbb
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
assert_data_files 'pop'
assert_rebase y
assert_dotgit_contents_for 'pop'

__test_section__ "Quit $APPLY_OPERATION stash"
printf 'fa4e08a58\n' >.git/ISTASH_STASH
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$APPLY_OPERATION" $COLOR_FLAGS "$QUIT_FLAG"
assert_outputs__apply__quit 'pop'
assert_files_HT '
UU aaa		ddd|bbb
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
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents_for 'none'
