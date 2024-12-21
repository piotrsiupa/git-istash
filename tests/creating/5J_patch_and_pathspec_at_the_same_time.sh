. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_PATHSPEC_STYLE

known_failure 'The default implementation doesn'\''t allow "--patch" and "--patchspec" together.'

__test_section__ 'Prepare repository'
printf 'aaa\naaa\n' >aaa
printf 'bbb\nbbb\n' >bbb
git add aaa bbb
git commit -m 'Added aaa & bbb'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'xxx\nbbb\nbbb\nxxx\n' >bbb
git add bbb
printf 'yyy\naaa\naaa\nyyy\n' >aaa
printf 'zzz\nbbb\nbbb\nzzz\n' >bbb
printf 's y n ' | tr ' ' '\n' >.git/answers_for_patch
if ! IS_PATHSPEC_NULL_SEP
then
	printf 'bbb\n' >.git/pathspec_for_test
else
	printf 'bbb\0' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS --patch --message 'this one is complicated' $KEEP_INDEX_FLAGS -m 'new stash' 'bbb'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS --patch --message 'this one is complicated' $KEEP_INDEX_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS --patch --message 'this one is complicated' $KEEP_INDEX_FLAGS -m 'new stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
if IS_KEEP_INDEX_OFF
then
	assert_files_H '
	 M aaa		yyy\naaa\naaa\nyyy	aaa\naaa
	 M bbb		bbb\nbbb\nzzz		bbb\nbbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_H '
	 M aaa		yyy\naaa\naaa\nyyy	aaa\naaa
	MM bbb		bbb\nbbb\nzzz		xxx\nbbb\nbbb\nxxx
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_H 0 'this one is complicated' '
MM bbb		zzz\nbbb\nbbb		xxx\nbbb\nbbb\nxxx
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
assert_branch_metadata_H

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
MM bbb		zzz\nbbb\nbbb		xxx\nbbb\nbbb\nxxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_H
