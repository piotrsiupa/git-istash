. "$commons_path" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'NO'
PARAMETRIZE_UNSTAGED 'NO'

__test_section__ 'Prepare repository'
touch aaa bbb
git add aaa bbb
git commit -m 'Added empty aaa and bbb'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'foo\nbar\n' >aaa
git add aaa
printf 'foo\nbar\n' >bbb
printf 'foo\nbar\n' >ccc
git add --intent-to-add ccc
printf '' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
GIT_EDITOR="sed -Ei '/^\+bar$/ d'" assert_exit_code 1 git istash "$CREATE_OPERATION" $STAGED_FLAGS $UNSTAGED_FLAGS $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS --patch --message 'some nice stash name' <.git/answers_for_patch
assert_files_HT '
M  aaa		foo\nbar
 M bbb		foo\nbar	<empty>
 A ccc		foo\nbar
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
