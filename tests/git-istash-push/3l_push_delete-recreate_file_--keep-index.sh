. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

exit 0  #TODO the test is disabled because `git stash` has a bug(?) and doesn't create the stash correctly in this case. (`git stash` is planned to not be used internally in `git istash` in the future.)

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

SWITCH_HEAD_TYPE

git rm aaa
printf 'bbb\n' >aaa
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash push --keep-index -u --message 'mesanmge'
assert_files_H '
D  aaa
!! ignored	ignored
'
assert_stash_H 0 'mesanmge' '
D  aaa
?? aaa		bbb
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

assert_exit_code 0 git stash pop --index
assert_files '
D  aaa
?? aaa		bbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
