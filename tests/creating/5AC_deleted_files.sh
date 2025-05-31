. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
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

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
git rm aaa
rm bbb
printf 'ddd\n' >ccc
git add ccc
rm ccc
printf 'ddd\n' >ddd
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS -mmsg
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	   aaa		aaa
	   bbb		bbb
	   ccc		ccc
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	D  aaa
	   bbb		bbb
	M  ccc			ddd
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_HT 0 'msg' '
D  aaa
 D bbb			bbb
MD ccc			ddd
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

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
D  aaa
 D bbb			bbb
MD ccc			ddd
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
