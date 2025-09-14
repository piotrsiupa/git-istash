. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
if IS_POP
then
	skip_silently # "pop" doesn't support branch names, which is checked in an ealier test
fi

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
git stash push -m 'the only stash'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash (without changes)"
correct_head_sha="$(get_head_sha_HT)"
assert_exit_code 1 git istash "$APPLY_OPERATION" HEAD^
assert_files_HT '
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents

__test_section__ "$CAP_APPLY_OPERATION stash (with changes)"
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
assert_exit_code 1 git istash "$APPLY_OPERATION" HEAD^
assert_files_HT '
AM aaa		bbb	aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
