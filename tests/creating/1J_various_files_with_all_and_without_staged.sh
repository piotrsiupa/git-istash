. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'NO'
PARAMETRIZE_UNSTAGED 'YES'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
printf 'ddd\n' >ddd
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS $ALL_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $UNTRACKED_FLAGS --message 'name of the new stash'
assert_files_H '
A  aaa		aaa
'
assert_stash_H 0 'name of the new stash' '
 A aaa		bbb
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents

git reset --hard
RESTORE_HEAD_TYPE

known_failure 'The standard "git stash pop" doesn'\''t support files added with "git add -N".'

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
 A aaa		bbb
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
