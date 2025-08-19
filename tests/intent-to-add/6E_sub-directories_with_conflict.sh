. "$commons_path" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Create stash'
mkdir xxx yyy
printf 'aaa0\n' >aaa
printf 'aaa1\n' >xxx/aaa
printf 'aaa2\n' >yyy/aaa
git add -N aaa xxx/aaa yyy/aaa
git istash push -u

__test_section__ 'Create conflict'
mkdir xxx yyy
printf 'bbb0\n' >aaa
printf 'bbb1\n' >xxx/aaa
printf 'bbb2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
git commit -m 'Added same files as in the stash'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
mkdir -p xxx
cd xxx
assert_exit_code 2 capture_outputs git istash "$APPLY_OPERATION"
cd -
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
AA aaa		bbb0|aaa0
AA xxx/aaa	bbb1|aaa1
AA yyy/aaa	bbb2|aaa2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (0)"
printf 'ccc0\n' >aaa
printf 'ccc1\n' >xxx/aaa
printf 'ccc2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
assert_exit_code 0 git istash "$APPLY_OPERATION" --continue
cd -
assert_files_HT '
 M aaa		ccc0	bbb0
 M xxx/aaa	ccc1	bbb1
 M yyy/aaa	ccc2	bbb2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
