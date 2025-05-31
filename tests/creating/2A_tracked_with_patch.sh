. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

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
printf 's y n s n y n y ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $STAGED_FLAGS $UNSTAGED_FLAGS $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS --patch --message 'some nice stash name' <.git/answers_for_patch
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	 M aaa		aaa\naaa\nyyy		aaa\naaa
	 M bbb		zzz\nbbb\nbbb		bbb\nbbb
	   ccc		ccc\nccc
	 D ddd		ddd\nddd
	   eee		eee\neee
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	MM aaa		xxx\naaa\naaa\nyyy	xxx\naaa\naaa\nxxx
	 M bbb		zzz\nbbb\nbbb		bbb\nbbb
	D  ccc
	 D ddd		ddd\nddd
	   eee		eee\neee
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_HT 0 'some nice stash name' '
MM aaa		yyy\naaa\naaa\nxxx	xxx\naaa\naaa\nxxx
 M bbb		bbb\nbbb\nzzz		bbb\nbbb
D  ccc
   ddd		ddd\nddd
 D eee		eee\neee
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
MM aaa		yyy\naaa\naaa\nxxx	xxx\naaa\naaa\nxxx
 M bbb		bbb\nbbb\nzzz		bbb\nbbb
D  ccc
   ddd		ddd\nddd
 D eee		eee\neee
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
