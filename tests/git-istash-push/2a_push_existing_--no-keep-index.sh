. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

printf 'aaa1\n' >aaa
printf 'bbb1\n' >bbb
printf 'ccc1\n' >ccc
printf 'ddd1\n' >ddd
git add aaa bbb ccc ddd
git commit -m 'Added aaa, bbb, ccc & ddd'

SWITCH_HEAD_TYPE

printf 'aaa2\n' >aaa
printf 'bbb2\n' >bbb
git add aaa bbb
printf 'bbb3\n' >bbb
printf 'ddd3\n' >ddd
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash push --no-keep-index
assert_files_H '
   aaa		aaa1
   bbb		bbb1
   ccc		ccc1
   ddd		ddd1
!! ignored	ignored
'
assert_stash_H 0 '' '
M  aaa			aaa2
MM bbb		bbb3	bbb2
   ccc		ccc1
 M ddd		ddd3	ddd1
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_name_H
assert_rebase n

RESTORE_HEAD_TYPE

assert_exit_code 0 git stash pop --index
assert_files '
M  aaa			aaa2
MM bbb		bbb3	bbb2
   ccc		ccc1
 M ddd		ddd3	ddd1
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
