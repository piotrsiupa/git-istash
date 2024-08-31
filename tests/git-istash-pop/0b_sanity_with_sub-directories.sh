. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

mkdir xxx yyy
if ! IS_HEAD_ORPHAN
then
	printf 'aaa0\n' >aaa
	printf 'aaa1\n' >xxx/aaa
	printf 'aaa2\n' >yyy/aaa
	git add aaa xxx/aaa yyy/aaa
	git commit -m 'Added aaa'
fi

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

correct_head_hash="$(get_head_hash_H)"
mkdir -p xxx
cd xxx
assert_exit_code 0 git stash pop --index
cd ..
assert_files_H '
MM aaa		ccc0	bbb0
MM xxx/aaa	ccc1	bbb1
MM yyy/aaa	ccc2	bbb2
?? zzz		zzz0
?? xxx/zzz	zzz1
?? yyy/zzz	zzz2
!! ignored	ignored
' '
AM aaa		ccc0	bbb0
AM xxx/aaa	ccc1	bbb1
AM yyy/aaa	ccc2	bbb2
?? zzz		zzz0
?? xxx/zzz	zzz1
?? yyy/zzz	zzz2
!! ignored	ignored
'
assert_stash_count 0
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
