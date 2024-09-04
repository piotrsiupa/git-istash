. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

known_failure 'an apparent bug in "git stash"'

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
rm aaa
printf 'ddd\n' >ddd
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash push --keep-index --message 'mesanmge'
assert_files_H '
A  aaa			aaa
?? ddd		ddd
!! ignored	ignored
'
assert_stash_H 0 'mesanmge' '
AD aaa			aaa
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
AD aaa			aaa
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
