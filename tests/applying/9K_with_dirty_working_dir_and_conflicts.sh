. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_CONTINUE

__test_section__ 'Prepare repository'
mkdir xxx yyy
printf 'aaa0\n' >aaa
printf 'aaa1\n' >xxx/aaa
printf 'aaa2\n' >yyy/aaa
printf 'aaa3\n' >bbb
printf 'aaa4\n' >xxx/bbb
printf 'aaa5\n' >yyy/bbb
git add aaa xxx/aaa yyy/aaa bbb xxx/bbb yyy/bbb
git commit -m 'Added a lot of files'

__test_section__ 'Create stash'
printf 'bbb0\n' >aaa
printf 'bbb1\n' >xxx/aaa
printf 'bbb2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
printf 'ccc0\n' >aaa
printf 'ccc1\n' >xxx/aaa
printf 'ccc2\n' >yyy/aaa
printf 'ccc3\n' >bbb
printf 'ccc4\n' >xxx/bbb
printf 'ccc5\n' >yyy/bbb
printf 'zzz0\n' >zzz
printf 'zzz1\n' >xxx/zzz
printf 'zzz2\n' >yyy/zzz
git stash push -u

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory & create conflict'
mkdir -p xxx yyy
printf 'ddd0\n' >aaa
printf 'ddd1\n' >xxx/aaa
printf 'ddd2\n' >yyy/aaa
printf 'ddd3\n' >bbb
printf 'ddd4\n' >xxx/bbb
printf 'ddd5\n' >yyy/bbb
git add aaa xxx/aaa yyy/aaa bbb xxx/bbb yyy/bbb
printf 'eee3\n' >bbb
printf 'eee4\n' >xxx/bbb
printf 'eee5\n' >yyy/bbb
printf 'yyy0\n' >zzz
printf 'yyy1\n' >xxx/zzz
printf 'yyy2\n' >yyy/zzz

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
mkdir -p xxx
cd xxx
assert_exit_code 2 git istash "$APPLY_OPERATION"
cd -
assert_outputs__apply__conflict "$APPLY_OPERATION" '
UU aaa
UU xxx/aaa
UU yyy/aaa
'
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU aaa		ddd0|bbb0
UU xxx/aaa	ddd1|bbb1
UU yyy/aaa	ddd2|bbb2
   bbb		ddd3
   xxx/bbb	ddd4
   yyy/bbb	ddd5
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (0)"
printf 'fff0\n' >aaa
printf 'fff1\n' >xxx/aaa
printf 'fff2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
assert_exit_code 2 git istash "$APPLY_OPERATION" "$CONTINUE_FLAG"
cd -
assert_outputs__apply__conflict "$APPLY_OPERATION" '
UU aaa
UU xxx/aaa
UU yyy/aaa
UU bbb
UU xxx/bbb
UU yyy/bbb
'
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU aaa		fff0|ccc0
UU xxx/aaa	fff1|ccc1
UU yyy/aaa	fff2|ccc2
UU bbb		eee3|ccc3
UU xxx/bbb	eee4|ccc4
UU yyy/bbb	eee5|ccc5
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (1)"
printf 'ggg0\n' >aaa
printf 'ggg1\n' >xxx/aaa
printf 'ggg2\n' >yyy/aaa
printf 'hhh3\n' >bbb
printf 'hhh4\n' >xxx/bbb
printf 'hhh5\n' >yyy/bbb
git add aaa xxx/aaa yyy/aaa bbb xxx/bbb yyy/bbb
cd xxx
assert_exit_code 2 git istash "$APPLY_OPERATION" "$CONTINUE_FLAG"
cd -
assert_outputs__apply__conflict "$APPLY_OPERATION" '
AA zzz
AA xxx/zzz
AA yyy/zzz
'
assert_conflict_message "$APPLY_OPERATION"
assert_files '
   aaa		ggg0
   xxx/aaa	ggg1
   yyy/aaa	ggg2
   bbb		hhh3
   xxx/bbb	hhh4
   yyy/bbb	hhh5
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
stash_sha="$(git rev-parse stash)"
cd xxx
assert_exit_code 0 git istash "$APPLY_OPERATION" "$CONTINUE_FLAG"
cd -
assert_outputs__apply__success "$APPLY_OPERATION" 0 "$stash_sha"
assert_files_HT '
MM aaa		ggg0	fff0
MM xxx/aaa	ggg1	fff1
MM yyy/aaa	ggg2	fff2
MM bbb		hhh3	ddd3
MM xxx/bbb	hhh4	ddd4
MM yyy/bbb	hhh5	ddd5
?? zzz		xxx0
?? xxx/zzz	xxx1
?? yyy/zzz	xxx2
!! ignored0	ignored0
!! ignored1	ignored1
' '
AM aaa		ggg0	fff0
AM xxx/aaa	ggg1	fff1
AM yyy/aaa	ggg2	fff2
AM bbb		hhh3	ddd3
AM xxx/bbb	hhh4	ddd4
AM yyy/bbb	hhh5	ddd5
?? zzz		xxx0
?? xxx/zzz	xxx1
?? yyy/zzz	xxx2
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
