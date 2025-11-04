. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
git add aaa bbb
git commit -m 'Added aaa & bbb'

__test_section__ 'Create stash'
printf 'xxx0\n' >aaa
git add aaa
printf 'xxx1\n' >aaa
printf 'ccc\n' >ccc
git stash push -u

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory'
printf 'yyy0\n' >bbb
git add bbb
printf 'yyy1\n' >bbb
printf 'ddd\n' >ddd

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha)"
stash_sha="$(git rev-parse stash)"
assert_exit_code 0 git istash "$APPLY_OPERATION"
assert_outputs__apply__success "$APPLY_OPERATION" 0 "$stash_sha"
assert_files_HT '
MM aaa		xxx1	xxx0
MM bbb		yyy1	yyy0
?? ccc		ccc
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
