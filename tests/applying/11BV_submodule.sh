. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_COLOR
PARAMETRIZE_QUIET
PARAMETRIZE_SUMMARY

__end_of_initialization__

prepare_repository

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git -c protocol.file.allow=always submodule add -b my-branch "$(dirname "$(dirname "$(dirname "$(pwd)")")")/remote-for-tests" the-sub-mod
printf 'bbb\n' >the-sub-mod/aaa
git -C the-sub-mod add aaa
printf 'ccc\n' >the-sub-mod/aaa
git commit -m 'Added aaa and a submodule'

cd the-sub-mod
correct_sub_mod_head_sha="$(get_head_sha)"
cd -

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'ddd\n' >ddd
git stash push -u

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash $QUIET_FLAGS "$APPLY_OPERATION" $SUMMARY_FLAGS $COLOR_FLAGS
assert_outputs__apply__success "$APPLY_OPERATION" '
MM aaa
?A ddd
' 0 "$stash_sha"
assert_files_HT '
MM aaa		ccc	bbb
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
   .gitmodules	[submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040my-branch
#  the-sub-mod	'"$correct_sub_mod_head_sha"'
## the-sub-mod/aaa
'
(
	set -eu
	cd the-sub-mod
	assert_files '
	MM aaa	ccc bbb
	'
	assert_stash_count 0
	assert_log_length 1
	assert_branch_count 1
	assert_head_sha "$correct_sub_mod_head_sha"
	assert_head_name 'my-branch'
	assert_rebase n
	assert_dotgit_contents
)
assert_stash_count_AO 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
