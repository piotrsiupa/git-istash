. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'NO'
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

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'xxx\naaa\naaa\nxxx\n' >aaa
git add aaa
printf 'yyy\naaa\naaa\nyyy\n' >aaa
printf 'zzz\nbbb\nbbb\nzzz\n' >bbb
git rm ccc
rm ddd eee
printf 's y n s n y n y ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $STAGED_FLAGS $UNSTAGED_FLAGS $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS --patch --message 'some nice stash name' <.git/answers_for_patch)"
assert_files_HTCO '
MM aaa		yyy\naaa\naaa\nyyy	xxx\naaa\naaa\nxxx
 M bbb		zzz\nbbb\nbbb\nzzz	bbb\nbbb
D  ccc
 D ddd		ddd\nddd
 D eee		eee\neee
!! ignored0	ignored0
!! ignored1	ignored1
' '
MM aaa		xxx\naaa\naaa\nyyy	xxx\naaa\naaa\nxxx
 M bbb		zzz\nbbb\nbbb		bbb\nbbb
D  ccc
 D ddd		ddd\nddd
   eee		eee\neee
!! ignored0	ignored0
!! ignored1	ignored1
'
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 'some nice stash name' '
 M aaa		yyy\naaa\naaa		aaa\naaa
 M bbb		bbb\nbbb\nzzz		bbb\nbbb
   ccc		ccc\nccc
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

remove_all_changes
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
 M aaa		yyy\naaa\naaa		aaa\naaa
 M bbb		bbb\nbbb\nzzz		bbb\nbbb
   ccc		ccc\nccc
   ddd		ddd\nddd
 D eee		eee\neee
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
