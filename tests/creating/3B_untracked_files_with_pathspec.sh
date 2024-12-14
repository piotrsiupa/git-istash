. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'xxx\n' >aaa0
printf 'xxx\n' >aaa1
printf 'xxx\n' >bbb2
printf 'xxx\n' >bbb3
printf 'xxx\n' >ccc4
printf 'xxx\n' >ccc5
printf 'xxx\n' >ddd6
printf 'xxx\n' >ddd7
printf 'xxx\n' >eee8
printf 'xxx\n' >eee9

if ! IS_PATHSPEC_NULL_SEP
then
	printf 'aaa0 bbb? *5 ./?dd* ' | tr ' ' '\n' >.git/pathspec_for_test
else
	printf 'aaa0 bbb? *5 ./?dd* ' | tr ' ' '\0' >.git/pathspec_for_test
fi
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push 'aaa0' $KEEP_INDEX_FLAGS $UNTRACKED_FLAGS 'bbb?' $ALL_FLAGS -m 'a stash' $EOI '*5' './?dd*'
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'a stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/pathspec_for_test
else                                                                                     
	#shellcheck disable=SC2086
	assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS -m 'a stash' $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test
fi
assert_files_H '
?? aaa1		xxx
?? ccc4		xxx
?? eee8		xxx
?? eee9		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_H 0 'a stash' '
?? aaa0		xxx
?? bbb2		xxx
?? bbb3		xxx
?? ccc5		xxx
?? ddd6		xxx
?? ddd7		xxx
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 1
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
?? aaa0		xxx
?? aaa1		xxx
?? bbb2		xxx
?? bbb3		xxx
?? ccc4		xxx
?? ccc5		xxx
?? ddd6		xxx
?? ddd7		xxx
?? eee8		xxx
?? eee9		xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_H
