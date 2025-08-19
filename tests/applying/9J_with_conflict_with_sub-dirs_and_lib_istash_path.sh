. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
mkdir xxx yyy
printf 'aaa0\n' >aaa
printf 'aaa1\n' >xxx/aaa
printf 'aaa2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
git commit -m 'Added aaa'

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
correct_head_hash="$(get_head_hash_HT)"
mkdir -p xxx
cd xxx
assert_exit_code 2 capture_outputs ../../../../../lib/git-istash/git-istash-"$APPLY_OPERATION"
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

__test_section__ "Continue $APPLY_OPERATION stash (0)"
printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
assert_exit_code 2 capture_outputs ../../../../../bin/git-istash "$APPLY_OPERATION" --continue
cd -
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU aaa		eee0|ccc0
UU xxx/aaa	eee1|ccc1
UU yyy/aaa	eee2|ccc2
   zzz		yyy0
   xxx/zzz	yyy1
   yyy/zzz	yyy2
!! ignored0	ignored0
!! ignored1	ignored1
' '
UU aaa		eee0|ccc0
UU xxx/aaa	eee1|ccc1
UU yyy/aaa	eee2|ccc2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (1)"
printf 'fff0\n' >aaa
printf 'fff1\n' >xxx/aaa
printf 'fff2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
if [ "$HEAD_TYPE" != 'ORPHAN' ]
then
	cd xxx
	assert_exit_code 2 capture_outputs ../../../../../bin/git-istash "$APPLY_OPERATION" --continue
	cd -
	assert_conflict_message "$APPLY_OPERATION"
	assert_files '
	   aaa		fff0
	   xxx/aaa	fff1
	   yyy/aaa	fff2
	AA zzz		yyy0|zzz0
	AA xxx/zzz	yyy1|zzz1
	AA yyy/zzz	yyy2|zzz2
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
	assert_stash_count 1
	assert_branch_count_HT 1
	assert_data_files "$APPLY_OPERATION"
	assert_rebase y
	assert_dotgit_contents_for "$APPLY_OPERATION"
	
	__test_section__ "Continue $APPLY_OPERATION stash (2)"
	printf 'xxx0\n' >zzz
	printf 'xxx1\n' >xxx/zzz
	printf 'xxx2\n' >yyy/zzz
	git add zzz xxx/zzz yyy/zzz
fi
cd xxx
assert_exit_code 0 ../../../../../bin/git-istash "$APPLY_OPERATION" --continue
cd -
assert_files_HT '
MM aaa		fff0	eee0
MM xxx/aaa	fff1	eee1
MM yyy/aaa	fff2	eee2
 M zzz		xxx0	yyy0
 M xxx/zzz	xxx1	yyy1
 M yyy/zzz	xxx2	yyy2
!! ignored0	ignored0
!! ignored1	ignored1
' '
AM aaa		fff0	eee0
AM xxx/aaa	fff1	eee1
AM yyy/aaa	fff2	eee2
?? zzz		zzz0
?? xxx/zzz	zzz1
?? yyy/zzz	zzz2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 3
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
