. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_KEEP_INDEX

known_failure 'The default implementation in "git stash" doesn'\''t allow continuing when no change is selected.'

__test_section__ 'Prepare repository'
printf 'aaa\naaa\n' >aaa
printf 'bbb\nbbb\n' >bbb
git add aaa bbb
git commit -m 'Added aaa & bbb'

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'xxx\naaa\naaa\nxxx\n' >aaa
git add aaa
printf 'yyy\naaa\naaa\nyyy\n' >aaa
printf 'zzz\nbbb\nbbb\nzzz\n' >bbb
correct_head_hash="$(get_head_hash_H)"
printf 'q ' | tr ' ' '\n' >.git/answers_for_patch
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS --patch --message 'some nice stash name' <.git/answers_for_patch
if IS_KEEP_INDEX_OFF
then
	assert_files_H '
	 M aaa		yyy\naaa\naaa\nyyy	aaa\naaa
	 M bbb		zzz\nbbb\nbbb\nzzz	bbb\nbbb
	!! ignored	ignored
	'
else
	assert_files_H '
	MM aaa		yyy\naaa\naaa\nyyy	xxx\naaa\naaa\nxxx
	 M bbb		zzz\nbbb\nbbb\nzzz	bbb\nbbb
	!! ignored	ignored
	'
fi
assert_stash_H 0 'some nice stash name' '
M  aaa		aaa\naaa	xxx\naaa\naaa\nxxx
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
 M bbb		zzz\nbbb\nbbb\nzzz	bbb\nbbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
