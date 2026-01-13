. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_QUIT

__end_of_initialization__

__test_section__ 'Create stash'
mkdir xxx yyy
printf 'aaa0\n' >aaa
printf 'aaa1\n' >xxx/aaa
printf 'aaa2\n' >yyy/aaa
git add -N aaa xxx/aaa yyy/aaa
git istash push -u

__test_section__ 'Create conflict'
mkdir xxx yyy
printf 'bbb0\n' >aaa
printf 'bbb1\n' >xxx/aaa
printf 'bbb2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
git commit -m 'Added same files as in the stash'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
mkdir -p xxx
cd xxx
assert_exit_code 2 git istash "$APPLY_OPERATION"
cd -
assert_outputs__apply__conflict "$APPLY_OPERATION" '
AA aaa
AA xxx/aaa
AA yyy/aaa
'
assert_files_HT '
AA aaa		bbb0|aaa0
AA xxx/aaa	bbb1|aaa1
AA yyy/aaa	bbb2|aaa2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Quit $APPLY_OPERATION stash"
printf 'ccc0\n' >aaa
printf 'ccc1\n' >xxx/aaa
printf 'ccc2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
correct_head_sha="$(get_head_sha_HT)"
cd xxx
assert_exit_code 0 git istash "$APPLY_OPERATION" "$QUIT_FLAG"
cd -
assert_outputs__apply__quit "$APPLY_OPERATION"
assert_files_HT '
M  aaa		ccc0
M  xxx/aaa	ccc1
M  yyy/aaa	ccc2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_head_sha_HT "$correct_head_sha"
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents_for 'none'
