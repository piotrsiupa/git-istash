. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_KEEP_INDEX

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
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS --message 'mesanmge'
if ! IS_KEEP_INDEX_ON
then
	assert_files_H '
	   aaa		aaa
	   bbb		bbb
	   ccc		ccc
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_H '
	D  aaa
	   bbb		bbb
	M  ccc			ddd
	?? ddd		ddd
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_H 0 'mesanmge' '
D  aaa
 D bbb			bbb
MD ccc			ddd
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n

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
