. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
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
printf 'ccc\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ 'Pop stash'
#shellcheck disable=SC2086
assert_exit_code 2 git istash pop $COLOR_FLAGS
assert_outputs__apply__conflict_HT 'pop' '
UU aaa
' '
DU aaa
'
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
assert_data_files 'pop'
assert_rebase y
assert_dotgit_contents_for 'pop'

__test_section__ 'Quit popping stash'
rm .git/ISTASH_TARGET
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash $COLOR_FLAGS "$QUIT_FLAG"
assert_outputs__apply__quit 'pop'
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
assert_head_sha_HT "$correct_head_sha"
assert_rebase n
assert_dotgit_contents_for 'none'
