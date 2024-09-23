. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_KEEP_INDEX

known_failure 'Default implementation of "git stash" returns 0 after failing to create a stash.'

SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
correct_head_hash="$(get_head_hash_H)"
printf 'y n ' | tr ' ' '\n' >.git/answers_for_patch
assert_exit_code 1 git istash push --patch $KEEP_INDEX_FLAGS --no-include-untracked <.git/answers_for_patch
assert_files_H '
?? aaa		aaa
?? bbb		bbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length_H 1
assert_branch_count 1
assert_head_name_H
assert_rebase n
