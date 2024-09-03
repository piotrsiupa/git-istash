. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
printf 'ccc\n' >ccc
git add aaa bbb ccc
git commit -m 'Added aaa, bbb & ccc'

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
git rm aaa
rm bbb
printf 'ddd\n' >ccc
git add ccc
rm ccc
printf 'ddd\n' >ddd
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash push --no-keep-index --message 'mesanmge'
assert_files_H '
   aaa		aaa
   bbb		bbb
   ccc		ccc
?? ddd		ddd
!! ignored	ignored
'
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

RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
D  aaa
 D bbb			bbb
MD ccc			ddd
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
