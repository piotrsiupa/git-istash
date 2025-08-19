. "$commons_path" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'NO'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'NO'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'xxx\n' >aaa0
printf 'xxx\n' >aaa1
printf 'xxx\n' >aaa2
printf 'xxx\n' >bbb3
printf 'xxx\n' >bbb4
printf 'xxx\n' >bbb5
printf 'xxx\n' >ccc6
printf 'xxx\n' >ccc7
printf 'xxx\n' >ccc8
printf 'xxx\n' >ddd9
printf 'xxx\n' >ddd10
printf 'xxx\n' >ddd11
printf 'xxx\n' >eee12
printf 'xxx\n' >eee13
printf 'xxx\n' >eee14
git add -N .
printf 'aaa0 bbb? *7 ./?dd* ' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash "$CREATE_OPERATION" 'aaa0' $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS 'bbb?' $EOI '*7' './?dd*'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else
	#shellcheck disable=SC2086
	assert_exit_code 1 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
assert_files_HTCO '
 A aaa0		xxx
 A aaa1		xxx
 A aaa2		xxx
 A bbb3		xxx
 A bbb4		xxx
 A bbb5		xxx
 A ccc6		xxx
 A ccc7		xxx
 A ccc8		xxx
 A ddd9		xxx
 A ddd10	xxx
 A ddd11	xxx
 A eee12	xxx
 A eee13	xxx
 A eee14	xxx
!! ignored0	ignored0
!! ignored1	ignored1
' '
 A aaa0		xxx
 A aaa1		xxx
 A aaa2		xxx
 A bbb3		xxx
 A bbb4		xxx
 A bbb5		xxx
 A ccc6		xxx
 A ccc7		xxx
 A ccc8		xxx
 A ddd9		xxx
 A ddd10	xxx
 A ddd11	xxx
 A eee12	xxx
 A eee13	xxx
 A eee14	xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
