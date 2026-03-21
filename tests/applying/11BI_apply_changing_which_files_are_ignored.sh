. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_COLOR

__end_of_initialization__

prepare_repository

__test_section__ 'Prepare repository'
printf 'aaa\nbbb\nccc\nddd\n' >.gitignore
git add .gitignore
git commit -m 'Added .gitignore'

__test_section__ 'Create stash'
printf 'aaa\nbbb\nccc\nyyy\n' >.gitignore
printf 'aaa\n' >aaa
printf 'zzz\n' >zzz
assert_files_HT '
 M .gitignore	aaa\nbbb\nccc\nyyy	aaa\nbbb\nccc\nddd
!! aaa		aaa
?? zzz		zzz
!! ignored0	ignored0
!! ignored1	ignored1
'
git stash push -ua

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory'
printf 'zzz\nbbb\nccc\nddd\n' >.gitignore
printf 'ddd\n' >ddd
printf 'yyy\n' >yyy
assert_files_HT '
 M .gitignore	zzz\nbbb\nccc\nddd	aaa\nbbb\nccc\nddd
!! ddd		ddd
?? yyy		yyy
'

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$APPLY_OPERATION" $COLOR_FLAGS
assert_outputs__apply__success "$APPLY_OPERATION" '
 M .gitignore
?A aaa
?A ddd
!! yyy
!A zzz
!A ignored0
!A ignored1
' 0 "$stash_sha"
assert_files_HT '
 M .gitignore	zzz\nbbb\nccc\nyyy	aaa\nbbb\nccc\nddd
?? aaa		aaa
?? ddd		ddd
!! yyy		yyy
!! zzz		zzz
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
