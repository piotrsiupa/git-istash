. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Create pre-existing stash (0)'
printf 'xxx\n' >aaa
git stash push -um 'pre-existing stash 0'

__test_section__ 'Create pre-existing stash (1)'
printf 'yyy\n' >aaa
git add aaa
printf 'zzz\n' >aaa
git stash push -m 'pre-existing stash 1'

assert_stash_count 2

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
correct_pre_stash_hash_0="$(get_stash_hash 1)"
correct_pre_stash_hash_1="$(get_stash_hash 0)"
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
printf 'ddd\n' >ddd
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $ALL_FLAGS $UNTRACKED_FLAGS $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	A  aaa			aaa
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_HT 0 '' '
AM aaa		bbb	aaa
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 3
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_stash_hash 2 "$correct_pre_stash_hash_0"
assert_stash_hash 1 "$correct_pre_stash_hash_1"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
AM aaa		bbb	aaa
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 2
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
