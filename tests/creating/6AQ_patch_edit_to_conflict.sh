. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
printf 'aaa1\n' >aaa
printf 'bbb1\n' >bbb
printf 'ccc1\n' >ccc
printf 'ddd1\n' >ddd
git add aaa bbb ccc ddd
git commit -m 'Added aaa, bbb, ccc & ddd'

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'aaa2\n' >aaa
printf 'bbb2\n' >bbb
git add aaa bbb
printf 'ccc2\n' >ccc
printf 'ddd2\n' >ddd
printf 'eee2\n' >eee
printf 'fff2\n' >fff
printf 'e n ' | tr ' ' '\n' >.git/answers_for_patch0
printf 'e n ' | tr ' ' '\n' >.git/answers_for_patch1
new_stash_sha_CO="$(
	{
		 cat .git/answers_for_patch0
		 sleep 5  # On Windows a child shell tends to eat all the stdin if it's able to. This prevents it. If it still doesn't work, try to increase the time.
		 cat .git/answers_for_patch1
	} | {
		#shellcheck disable=SC2086
		GIT_EDITOR="sed -Ei 's/^\+[a-z]{3}2/+xxx/'" assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS --patch $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS
		assert_outputs__create__success '1,1' '1,1'
	}
)"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	M  aaa		aaa2
	M  bbb		bbb2
	 M ccc		ccc2	ccc1
	 M ddd		ddd2	ddd1
	?? eee		eee2
	?? fff		fff2
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	   aaa		aaa1
	   bbb		bbb1
	 M ccc		ccc2	ccc1
	 M ddd		ddd2	ddd1
	?? eee		eee2
	?? fff		fff2
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HTCO '
	M  aaa		aaa2
	M  bbb		bbb2
	 M ccc		ccc2	ccc1
	 M ddd		ddd2	ddd1
	?? eee		eee2
	?? fff		fff2
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	M  aaa		aaa2
	M  bbb		bbb2
	 M ccc		ccc2	ccc1
	 M ddd		ddd2	ddd1
	?? eee		eee2
	?? fff		fff2
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
M  aaa		aaa2
M  bbb		bbb2
 M ccc		xxx	ccc1
   ddd		ddd1
?? eee		xxx
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes
git clean -df
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
M  aaa		aaa2
M  bbb		bbb2
 M ccc		xxx	ccc1
   ddd		ddd1
?? eee		xxx
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
