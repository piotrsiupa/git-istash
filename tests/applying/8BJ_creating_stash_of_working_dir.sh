. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Create stash'
printf 'xxx0\n' >aaa
git add aaa
printf 'xxx1\n' >aaa
git stash push
stash_sha="$(git rev-parse stash)"

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory'
printf 'yyy0\n' >bbb
git add bbb
printf 'yyy1\n' >bbb

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
assert_exit_code 0 git istash "$APPLY_OPERATION"
assert_files_HT '
AM aaa		xxx1	xxx0
AM bbb		yyy1	yyy0
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

__test_section__ 'Store stash of working directory changes'
old_working_dir_stash="$(printf '%s\n' "$stdout" | sed -E -n 's/^Stash of the old working dir: ([0-9a-zA-Z]{7,40})$/\1/ p')"
git stash store "$old_working_dir_stash" --message="$(git show -s --format=%B "$old_working_dir_stash")"
assert_stash_HT 0 "Working directory changes prior to applying stash $stash_sha" '
AM bbb		yyy1	yyy0
'
assert_stash_count_AO 2

__test_section__ 'Restore old working directory'
remove_all_changes
assert_exit_code 0 git istash pop
assert_files_HT '
AM bbb		yyy1	yyy0
'
assert_stash_count_AO 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
