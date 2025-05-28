. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_POP

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

__test_section__ "$CAP_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
mkdir -p xxx
cd xxx
assert_exit_code 2 capture_outputs git istash "$OPERATION"
cd -
assert_conflict_message
assert_files_H '
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
assert_branch_count_H 1
assert_data_files "$OPERATION"
assert_rebase y
assert_dotgit_contents_for "$OPERATION"

__test_section__ "Continue $OPERATION stash (0)"
printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
assert_exit_code 2 capture_outputs git istash "$OPERATION" --continue
cd -
assert_conflict_message
assert_files_H '
UU aaa		eee0|ccc0
UU xxx/aaa	eee1|ccc1
UU yyy/aaa	eee2|ccc2
AA zzz		yyy0|zzz0
AA xxx/zzz	yyy1|zzz1
AA yyy/zzz	yyy2|zzz2
!! ignored0	ignored0
!! ignored1	ignored1
' '
UU aaa		eee0|ccc0
UU xxx/aaa	eee1|ccc1
UU yyy/aaa	eee2|ccc2
A  zzz		zzz0
A  xxx/zzz	zzz1
A  yyy/zzz	zzz2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_H 1
assert_data_files "$OPERATION"
assert_rebase y
assert_dotgit_contents_for "$OPERATION"

__test_section__ "Continue $OPERATION stash (1)"
printf 'fff0\n' >aaa
printf 'fff1\n' >xxx/aaa
printf 'fff2\n' >yyy/aaa
printf 'xxx0\n' >zzz
printf 'xxx1\n' >xxx/zzz
printf 'xxx2\n' >yyy/zzz
git add aaa xxx/aaa yyy/aaa zzz xxx/zzz yyy/zzz
cd xxx
assert_exit_code 0 git istash "$OPERATION" --continue
cd -
assert_files_H '
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
?? zzz		xxx0
?? xxx/zzz	xxx1
?? yyy/zzz	xxx2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_O 1
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
