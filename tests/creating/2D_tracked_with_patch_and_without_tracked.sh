. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'NO'
PARAMETRIZE_UNSTAGED 'NO'

__test_section__ 'Prepare repository'
printf 'aaa\naaa\n' >aaa
printf 'bbb\nbbb\n' >bbb
printf 'ccc\nccc\n' >ccc
printf 'ddd\nddd\n' >ddd
printf 'eee\neee\n' >eee
git add aaa bbb ccc ddd eee
git commit -m 'Added aaa & bbb'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'xxx\naaa\naaa\nxxx\n' >aaa
git add aaa
printf 'yyy\naaa\naaa\nyyy\n' >aaa
printf 'zzz\nbbb\nbbb\nzzz\n' >bbb
git rm ccc
rm ddd eee
printf '' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
assert_exit_code 1 git istash push $STAGED_FLAGS $UNSTAGED_FLAGS $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS --patch --message 'some nice stash name' <.git/answers_for_patch
assert_files_H '
MM aaa		yyy\naaa\naaa\nyyy	xxx\naaa\naaa\nxxx
 M bbb		zzz\nbbb\nbbb\nzzz	bbb\nbbb
D  ccc
 D ddd		ddd\nddd
 D eee		eee\neee
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
