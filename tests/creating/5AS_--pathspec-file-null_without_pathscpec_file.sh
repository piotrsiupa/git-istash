. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_ALL
PARAMETRIZE_UNTRACKED
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
git add aaa bbb
printf 'ccc\n' >ccc
printf 'ddd\n' >ddd
#shellcheck disable=SC2086
assert_exit_code 1 git istash push $UNTRACKED_FLAGS $ALL_FLAGS --pathspec-file-nul $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS
assert_files_H '
A  aaa		aaa
A  bbb		bbb
?? ccc		ccc
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_H 1
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
