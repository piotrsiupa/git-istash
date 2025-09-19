. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git stash push

__test_section__ 'Create conflict'
printf 'ccc\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ 'Apply stash'
correct_head_sha_0="$(get_head_sha_HT)"
assert_exit_code 2 capture_outputs git istash apply
assert_files_HT '
UU aaa		ccc|bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
DU aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_rebase y
assert_dotgit_contents_for 'apply'

__test_section__ "$CAP_CREATE_OPERATION stash again"
correct_head_sha_1="$(get_head_sha_HT)"
assert_exit_code 1 git istash "$CREATE_OPERATION"
assert_files_HT '
UU aaa		ccc|bbb
!! ignored0	ignored0
!! ignored1	ignored1
' '
DU aaa		bbb
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_head_sha_HT "$correct_head_sha_1"
assert_rebase y
assert_dotgit_contents_for 'apply'

__test_section__ 'Continue the first apply stash'
printf 'ddd\n' >aaa
git add aaa
assert_exit_code 0 git istash apply --continue
assert_files_HT '
 M aaa		ddd	ccc
!! ignored0	ignored0
!! ignored1	ignored1
' '
 A aaa		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_head_sha_HT "$correct_head_sha_0"
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
