. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'xxx\naaa\naaa\nxxx\n' >aaa
git add aaa
printf 'yyy\naaa\naaa\nyyy\n' >aaa
printf 's y n ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS --patch <.git/answers_for_patch
assert_outputs__create__success '3'
new_stash_sha_CO="$stdout"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	AM aaa		yyy\naaa\naaa\nyyy	xxx\naaa\naaa\nxxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	 A aaa		xxx\naaa\naaa\nyyy
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HTCO '
	AM aaa		yyy\naaa\naaa\nyyy	xxx\naaa\naaa\nxxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	AM aaa		xxx\naaa\naaa\nyyy	xxx\naaa\naaa\nxxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
AM aaa		yyy\naaa\naaa\nxxx	xxx\naaa\naaa\nxxx
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
rm -f aaa
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
AM aaa		yyy\naaa\naaa\nxxx	xxx\naaa\naaa\nxxx
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
