. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
mkdir xxx yyy
if ! IS_HEAD_ORPHAN
then
	printf 'aaa0\n' >aaa
	printf 'aaa1\n' >xxx/aaa
	printf 'aaa2\n' >yyy/aaa
	git add aaa xxx/aaa yyy/aaa
	git commit -m 'Added aaa'
fi

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

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_H)"
mkdir -p xxx
cd xxx
assert_exit_code 0 git stash "$APPLY_OPERATION" --index
cd -
assert_files_H '
MM aaa		ccc0	bbb0
MM xxx/aaa	ccc1	bbb1
MM yyy/aaa	ccc2	bbb2
?? zzz		zzz0
?? xxx/zzz	zzz1
?? yyy/zzz	zzz2
!! ignored0	ignored0
!! ignored1	ignored1
' '
AM aaa		ccc0	bbb0
AM xxx/aaa	ccc1	bbb1
AM yyy/aaa	ccc2	bbb2
?? zzz		zzz0
?? xxx/zzz	zzz1
?? yyy/zzz	zzz2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_O 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
