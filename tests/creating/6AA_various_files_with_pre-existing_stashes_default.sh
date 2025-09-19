. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
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

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
correct_pre_stash_sha_0="$(get_stash_sha 1)"
correct_pre_stash_sha_1="$(get_stash_sha 0)"
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
printf 'ddd\n' >ddd
#shellcheck disable=SC2086
new_stash_sha_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $ALL_FLAGS $UNTRACKED_FLAGS $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS)"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	AM aaa		bbb	aaa
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HTCO '
	AM aaa		bbb	aaa
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	A  aaa			aaa
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
AM aaa		bbb	aaa
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 3
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_stash_sha 2 "$correct_pre_stash_sha_0"
assert_stash_sha 1 "$correct_pre_stash_sha_1"
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
assert_stash_count 2
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
