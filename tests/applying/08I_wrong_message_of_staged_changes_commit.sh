. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

__end_of_initialization__

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create a broken stash manually'
printf 'bbb\n' >aaa
git add aaa
git commit -m 'wrong message'
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
assert_exit_code 1 git istash apply "$stash_sha"
assert_outputs__apply__wrong_stash_commit_messages "$stash_sha"
assert_files_HT '
   aaa		aaa
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
