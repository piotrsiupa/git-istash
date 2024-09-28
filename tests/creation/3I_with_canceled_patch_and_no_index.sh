. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_KEEP_INDEX

__test_section__ 'Prepare repository'
printf 'aaa\naaa\n' >aaa
printf 'bbb\nbbb\n' >bbb
git add aaa bbb
git commit -m 'Added aaa & bbb'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'yyy\naaa\naaa\nyyy\n' >aaa
printf 'zzz\nbbb\nbbb\nzzz\n' >bbb
printf 'q ' | tr ' ' '\n' >.git/answers_for_patch
assert_exit_code 1 git istash push $KEEP_INDEX_FLAGS --patch --message 'some nice stash name' <.git/answers_for_patch
assert_files_H '
 M aaa		yyy\naaa\naaa\nyyy	aaa\naaa
 M bbb		zzz\nbbb\nbbb\nzzz	bbb\nbbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
