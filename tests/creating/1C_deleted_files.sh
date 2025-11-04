. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
printf 'ccc\n' >ccc
git add aaa bbb ccc
git commit -m 'Added aaa, bbb & ccc'

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
git rm bbb
rm ccc
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS
assert_outputs__create__success
new_stash_sha_CO="$stdout"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	   aaa		aaa
	D  bbb
	 D ccc		ccc
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	   aaa		aaa
	   bbb		bbb
	   ccc		ccc
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HTCO '
	   aaa		aaa
	D  bbb
	 D ccc		ccc
	!! ignored0	ignored0
	!! ignored1	ignored1
	' '
	   aaa		aaa
	D  bbb
	   ccc		ccc
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
   aaa		aaa
D  bbb
 D ccc		ccc
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
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
   aaa		aaa
D  bbb
 D ccc		ccc
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
