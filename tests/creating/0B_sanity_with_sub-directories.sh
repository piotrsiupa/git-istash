. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION 'push'

__test_section__ 'Prepare repository'
mkdir xxx yyy
printf 'aaa0\n' >aaa
printf 'aaa1\n' >xxx/aaa
printf 'aaa2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
git commit -m 'Added aaa'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
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
	assert_exit_code 0 git stash "$CREATE_OPERATION" -u -m 'name'
	cd -
	assert_files_HTCO '' '
	   aaa		aaa0
	   xxx/aaa	aaa1
	   yyy/aaa	aaa2
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
	assert_stash_HTCO 0 'name' '
	MM aaa		ccc0	bbb0
	MM xxx/aaa	ccc1	bbb1
	MM yyy/aaa	ccc2	bbb2
	?? zzz		zzz0
	?? xxx/zzz	zzz1
	?? yyy/zzz	zzz2
	'
	assert_stash_base_HT 0 'HEAD'
	assert_stash_count 1
	assert_log_length_HT 2
	assert_branch_count 1
	assert_head_hash_HT "$correct_head_hash"
	assert_head_name_HT
	assert_rebase n
	assert_branch_metadata_HT
	assert_dotgit_contents
else
	cd xxx
	if git stash "$CREATE_OPERATION" -u --message 'some name'
	then
		# This doesn't work in normal `git stash`
		exit 1
	fi
	cd -
fi
