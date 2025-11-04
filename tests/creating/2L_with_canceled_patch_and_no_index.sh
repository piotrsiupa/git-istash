. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL
PARAMETRIZE_UNTRACKED
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
printf 'aaa\naaa\n' >aaa
printf 'bbb\nbbb\n' >bbb
git add aaa bbb
git commit -m 'Added aaa & bbb'

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'yyy\naaa\naaa\nyyy\n' >aaa
printf 'zzz\nbbb\nbbb\nzzz\n' >bbb
printf 'q q ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
assert_exit_code 1 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $KEEP_INDEX_FLAGS --patch --message 'some nicer stash name' <.git/answers_for_patch
if IS_ALL_ON
then
	assert_outputs__create__no_changes_to_stash '1' '1'
elif IS_UNTRACKED_ON
then
	assert_outputs__create__no_changes_to_stash '1' ''
else
	assert_outputs__create__no_changes_to_stash '1'
fi
assert_files_HT '
 M aaa		yyy\naaa\naaa\nyyy	aaa\naaa
 M bbb		zzz\nbbb\nbbb\nzzz	bbb\nbbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
