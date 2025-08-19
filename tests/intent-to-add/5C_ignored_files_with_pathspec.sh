. "$commons_path" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'NO'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'xxx\n' >aaa0
printf 'xxx\n' >aaa1
printf 'xxx\n' >bbb0
printf 'xxx\n' >bbb1
printf 'xxx\n' >ccc0
printf 'xxx\n' >ccc1
printf 'xxx\n' >ddd0
printf 'xxx\n' >ddd1
git add -N aaa0 aaa1 bbb0 bbb1 ccc0 ccc1 ddd0 ddd1
printf '*0\n' >.gitignore
printf 'aaa0 bbb? ./*d1' | PREPARE_PATHSPEC_FILE
if IS_PATHSPEC_IN_ARGS
then
	#shellcheck disable=SC2086
	new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" 'aaa0' $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS 'bbb?' -mnameish\ name $EOI './*d1')"
elif IS_PATHSPEC_IN_STDIN
then
	#shellcheck disable=SC2086
	new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file=- -mnameish\ name <.git/pathspec_for_test)"
else
	#shellcheck disable=SC2086
	new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $PATHSPEC_NULL_FLAGS --pathspec-from-file .git/pathspec_for_test -mnameish\ name)"
fi
assert_files_HTCO '
 A aaa0		xxx
 A aaa1		xxx
 A bbb0		xxx
 A bbb1		xxx
 A ccc0		xxx
 A ccc1		xxx
 A ddd0		xxx
 A ddd1		xxx
?? .gitignore	*0
!! ignored0	ignored0
!! ignored1	ignored1
' '
 A aaa1		xxx
 A ccc0		xxx
 A ccc1		xxx
 A ddd0		xxx
?? .gitignore	*0
!! ignored0	ignored0
!! ignored1	ignored1
'
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 'nameish name' '
 A aaa0		xxx
 A bbb0		xxx
 A bbb1		xxx
 A ddd1		xxx
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git istash pop
assert_files '
 A aaa0		xxx
 A bbb0		xxx
 A bbb1		xxx
 A ddd1		xxx
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
