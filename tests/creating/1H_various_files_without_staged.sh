. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'NO'
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
assert_exit_code 0 git istash push $UNSTAGED_FLAGS $STAGED_FLAGS $KEEP_INDEX_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS --message 'name'
assert_files_HT '
A  aaa		aaa
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_HT 0 'name' '
 A aaa		bbb
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
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
assert_branch_metadata_HT
assert_dotgit_contents
