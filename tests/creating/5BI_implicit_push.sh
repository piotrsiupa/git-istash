. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "Push stash (implicitly)"
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
printf 'ddd\n' >ddd
#shellcheck disable=SC2086
assert_exit_code 0 git istash
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
assert_exit_code 0 git stash pop --index
assert_files '
AM aaa		bbb	aaa
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
