. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX

known_failure 'The default implementation in "git stash" makes no sense.'

__test_section__ 'Prepare repository'
printf 'aaa\naaa\n' >aaa
printf 'bbb\nbbb\n' >bbb
git add aaa bbb
git commit -m 'Added aaa & bbb'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'xxx\naaa\naaa\nxxx\n' >aaa
git add aaa
printf 'yyy\naaa\naaa\nyyy\n' >aaa
printf 'zzz\nbbb\nbbb\nzzz\n' >bbb
printf 's y n s n y ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS --patch --message 'some nice stash name' <.git/answers_for_patch
if IS_KEEP_INDEX_OFF
then
	assert_files_H '
	 M aaa		aaa\naaa\nyyy		aaa\naaa
	 M bbb		zzz\nbbb\nbbb		bbb\nbbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_H '
	MM aaa		xxx\naaa\naaa\nyyy	xxx\naaa\naaa\nxxx
	 M bbb		zzz\nbbb\nbbb		bbb\nbbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_H 0 'some nice stash name' '
MM aaa		yyy\naaa\naaa\nxxx	xxx\naaa\naaa\nxxx
 M bbb		bbb\nbbb\nzzz		bbb\nbbb
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
MM aaa		yyy\naaa\naaa\nxxx	xxx\naaa\naaa\nxxx
 M bbb		bbb\nbbb\nzzz		bbb\nbbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
