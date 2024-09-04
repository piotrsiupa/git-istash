. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

__test_section__ 'Prepare repository'
mkdir xxx yyy
printf 'aaa0\n' >aaa
printf 'aaa1\n' >xxx/aaa
printf 'aaa2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
git commit -m 'Added aaa'

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
correct_head_hash="$(get_head_hash_H)"
mkdir -p xxx yyy
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
if ! IS_HEAD_ORPHAN
then
	cd xxx
	assert_exit_code 0 git stash push -u -m 'name'
	cd ..
	assert_files_H '
	   aaa		aaa0
	   xxx/aaa	aaa1
	   yyy/aaa	aaa2
	!! ignored	ignored
	'
	assert_stash_H 0 'name' '
	MM aaa		ccc0	bbb0
	MM xxx/aaa	ccc1	bbb1
	MM yyy/aaa	ccc2	bbb2
	?? zzz		zzz0
	?? xxx/zzz	zzz1
	?? yyy/zzz	zzz2
	'
	assert_stash_base_H 0 'HEAD'
	assert_stash_count 1
	assert_log_length_H 2
	assert_branch_count 1
	assert_head_hash_H "$correct_head_hash"
	assert_head_name_H
	assert_rebase n
else
	cd xxx
	if git stash push -u --message 'some name'
	then
		# This doesn't work in normal `git stash`
		exit 1
	fi
	cd ..
fi
