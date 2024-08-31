. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

printf 'xxx\n' >aaa
git stash push -um 'pre-existing stash 0'

printf 'yyy\n' >aaa
git add aaa
printf 'zzz\n' >aaa
git stash push -m 'pre-existing stash 1'

assert_stash_count 2

SWITCH_HEAD_TYPE

correct_pre_stash_hash_0="$(get_stash_hash 1)"
correct_pre_stash_hash_1="$(get_stash_hash 0)"
correct_head_hash="$(get_head_hash_H)"
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
printf 'ddd\n' >ddd
assert_exit_code 0 git istash push --keep-index
assert_files_H '
A  aaa			aaa
?? ddd		ddd
!! ignored	ignored
'
assert_stash_H 0 '' '
AM aaa		bbb	aaa
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 3
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_stash_hash 2 "$correct_pre_stash_hash_0"
assert_stash_hash 1 "$correct_pre_stash_hash_1"
assert_head_name_H
assert_rebase n

git reset --hard
RESTORE_HEAD_TYPE

assert_exit_code 0 git stash pop --index
assert_files '
AM aaa		bbb	aaa
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 2
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
