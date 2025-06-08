. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'ORPHAN'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE
git branch -m 'new-and-cool-branch'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	A  aaa			bbb
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash 0 'new-and-cool-branch' '' '
A  aaa		bbb
'
if ! IS_HEAD_ORPHAN
then
	assert_stash_base 0 'HEAD'
else
	assert_stash_base 0 '~new-and-cool-branch'
fi
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
if ! IS_HEAD_ORPHAN
then
	assert_head_name 'new-and-cool-branch'
else
	assert_head_name '~new-and-cool-branch'
fi
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
A  aaa		bbb
'
assert_stash_count 0
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
if ! IS_HEAD_ORPHAN
then
	assert_head_name 'new-and-cool-branch'
else
	assert_head_name '~new-and-cool-branch'
fi
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
