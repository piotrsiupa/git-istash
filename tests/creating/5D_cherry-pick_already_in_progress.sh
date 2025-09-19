. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
git branch -m branch0
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git stash push

__test_section__ 'Create conflicting branch'
git switch -c branch1
printf 'ccc\n' >aaa
git add aaa
git commit -m 'Changed something'
git switch branch0

SWITCH_HEAD_TYPE

__test_section__ 'Create conflict'
printf 'ddd\n' >aaa
git add aaa
git commit -m 'Changed something in a different way'

__test_section__ 'Cherry-pick branch'
git cherry-pick branch1 || true
assert_files_HT '
UU aaa		ddd|ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 3
assert_branch_count 2
assert_rebase n
assert_dotgit_contents

__test_section__ "$CAP_CREATE_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
assert_exit_code 1 git istash "$CREATE_OPERATION"
assert_files_HT '
UU aaa		ddd|ccc
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 3
assert_branch_count 2
assert_head_sha_HT "$correct_head_sha"
assert_rebase n
assert_dotgit_contents

__test_section__ "Continue cherry-pick"
printf 'eee\n' >aaa
git add aaa
echo asdsadfsadf >&2
git cherry-pick --continue
assert_files_HT '
   aaa		eee
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_log_length_HT 4
assert_branch_count 2
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
