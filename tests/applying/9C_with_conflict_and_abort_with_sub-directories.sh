. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_ABORT

__test_section__ 'Prepare repository'
mkdir xxx yyy
printf 'aaa0\n' >aaa
printf 'aaa1\n' >xxx/aaa
printf 'aaa2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
git commit -m 'Added a few files'

__test_section__ 'Create stash'
printf 'bbb0\n' >aaa
printf 'bbb1\n' >xxx/aaa
printf 'bbb2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
printf 'ccc0\n' >aaa
printf 'ccc1\n' >xxx/aaa
printf 'ccc2\n' >yyy/aaa
printf 'zzz0\n' >zzz
printf 'zzz1\n' >xxx/zzz
printf 'zzz2\n' >yyy/zzz
git stash push -u

__test_section__ 'Create conflict'
printf 'ddd0\n' >aaa
printf 'ddd1\n' >xxx/aaa
printf 'ddd2\n' >yyy/aaa
printf 'yyy0\n' >zzz
printf 'yyy1\n' >xxx/zzz
printf 'yyy2\n' >yyy/zzz
git add aaa xxx/aaa yyy/aaa zzz xxx/zzz yyy/zzz
git commit -m 'Changed aaa & added zzz'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
mkdir -p xxx
cd xxx
assert_exit_code 2 capture_outputs git istash "$APPLY_OPERATION"
cd -
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU aaa		ddd0|bbb0
UU xxx/aaa	ddd1|bbb1
UU yyy/aaa	ddd2|bbb2
   zzz		yyy0
   xxx/zzz	yyy1
   yyy/zzz	yyy2
!! ignored0	ignored0
!! ignored1	ignored1
' '
DU aaa		bbb0
DU xxx/aaa	bbb1
DU yyy/aaa	bbb2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Abort $APPLY_OPERATION stash"
printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
assert_exit_code 0 git istash "$APPLY_OPERATION" "$ABORT_FLAG"
cd -
assert_files_HT '
   aaa		ddd0
   xxx/aaa	ddd1
   yyy/aaa	ddd2
   zzz		yyy0
   xxx/zzz	yyy1
   yyy/zzz	yyy2
!! ignored0	ignored0
!! ignored1	ignored1
' '
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 3
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
