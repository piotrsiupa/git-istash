. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_COLOR

__end_of_initialization__

prepare_repository

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'aaa\n' >aaa
git add aaa
printf 'aaa\n' >bbb
git add -N bbb
printf 'bbb\n' >aaa
printf 'ddd\n' >ddd
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $ALL_FLAGS $COLOR_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $UNTRACKED_FLAGS --message 'name of the new stash'
assert_outputs__create__success '*' 0 'name of the new stash'
new_stash_sha_CO="$stdout"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	AM aaa		bbb	aaa
	 A bbb		aaa
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	'
else
	assert_files_HTCO '
	AM aaa		bbb	aaa
	 A bbb		aaa
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	A  aaa		aaa
	'
fi
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 'name of the new stash' '
AM aaa		bbb	aaa
 A bbb		aaa
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash pop $COLOR_FLAGS
assert_outputs__apply__success 'pop' '
AM aaa
 A bbb
?A ddd
!A ignored0
!A ignored1
' 0 "$stash_sha"
assert_files '
AM aaa		bbb	aaa
 A bbb		aaa
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
