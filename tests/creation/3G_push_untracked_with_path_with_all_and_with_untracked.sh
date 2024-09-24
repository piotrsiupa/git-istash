. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE 'ALL_FLAG' '-a' '--all'
PARAMETRIZE 'UNTRACKED_FLAG' '-u' '--include-untracked'

known_failure 'Default implementation of "git stash" doesn'\''t allow stashing untracked files.'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
printf 'y n y ' | tr ' ' '\n' >.git/answers_for_patch
assert_exit_code 0 git istash push --patch $KEEP_INDEX_FLAGS "$ALL_FLAG" "$UNTRACKED_FLAG" <.git/answers_for_patch
assert_files_H '
?? bbb		bbb
'
assert_stash_H 0 '' '
?? aaa		aaa
!! ignored	ignored
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
?? aaa		aaa
?? bbb		bbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
