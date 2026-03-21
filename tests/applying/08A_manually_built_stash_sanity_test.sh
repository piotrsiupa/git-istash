. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_COLOR

__end_of_initialization__

prepare_repository

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash manually'
printf 'bbb\n' >aaa
git add aaa
git commit -m "index on master: $(git show --no-patch --format='%h %s')"
index_commit_sha="$(git rev-parse HEAD)"
git reset --hard HEAD~
git merge --no-ff --no-commit "$index_commit_sha"
printf 'ccc\n' >aaa
git add aaa
GIT_EDITOR='sed -i "1s/^.*$/On master: my stash/"' git merge --continue
stash_sha="$(git rev-parse HEAD)"
git reset --hard HEAD~

SWITCH_HEAD_TYPE

__test_section__ 'Apply stash'
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash apply "$stash_sha" $COLOR_FLAGS
assert_outputs__apply__success apply '
MM aaa
' 0 "$stash_sha"
assert_files_HT '
MM aaa		ccc	bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
