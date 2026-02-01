. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_CONTINUE
PARAMETRIZE_QUIT
PARAMETRIZE_COLOR NO  # Randomly chosen value

__end_of_initialization__

prepare_repository

__test_section__ 'Create stash'
mkdir xxx yyy
printf 'bbb0\n' >aaa
printf 'bbb1\n' >xxx/aaa
printf 'bbb2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
printf 'ccc0\n' >aaa
printf 'ccc1\n' >xxx/aaa
printf 'ccc2\n' >yyy/aaa
printf 'ccc3\n' >bbb
printf 'ccc4\n' >xxx/bbb
printf 'ccc5\n' >yyy/bbb
git add -N bbb xxx/bbb yyy/bbb
printf 'zzz0\n' >zzz
printf 'zzz1\n' >xxx/zzz
printf 'zzz2\n' >yyy/zzz
git istash push -u

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory & create conflict'
mkdir -p xxx yyy
printf 'ddd0\n' >aaa
printf 'ddd1\n' >xxx/aaa
printf 'ddd2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
printf 'eee0\n' >aaa
printf 'eee1\n' >xxx/aaa
printf 'eee2\n' >yyy/aaa
printf 'eee3\n' >bbb
printf 'eee4\n' >xxx/bbb
printf 'eee5\n' >yyy/bbb
git add -N bbb xxx/bbb yyy/bbb
printf 'yyy0\n' >zzz
printf 'yyy1\n' >xxx/zzz
printf 'yyy2\n' >yyy/zzz

__test_section__ "$CAP_APPLY_OPERATION stash"
mkdir -p xxx
cd xxx
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $COLOR_FLAGS
cd -
assert_outputs__apply__conflict "$APPLY_OPERATION" '
AA aaa
AA xxx/aaa
AA yyy/aaa
'
assert_files_HT '
AA aaa		ddd0|bbb0
AA xxx/aaa	ddd1|bbb1
AA yyy/aaa	ddd2|bbb2
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (0)"
printf 'fff0\n' >aaa
printf 'fff1\n' >xxx/aaa
printf 'fff2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $COLOR_FLAGS "$CONTINUE_FLAG"
cd -
assert_outputs__apply__conflict "$APPLY_OPERATION" '
UU aaa
UU xxx/aaa
UU yyy/aaa
'
assert_files_HT '
UU aaa		fff0|eee0
UU xxx/aaa	fff1|eee1
UU yyy/aaa	fff2|eee2
A  bbb		eee3
A  xxx/bbb	eee4
A  yyy/bbb	eee5
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (1)"
printf 'ggg0\n' >aaa
printf 'ggg1\n' >xxx/aaa
printf 'ggg2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
cd xxx
#shellcheck disable=SC2086
assert_exit_code 2 git istash "$APPLY_OPERATION" $COLOR_FLAGS "$CONTINUE_FLAG"
cd -
assert_outputs__apply__conflict "$APPLY_OPERATION" '
UU aaa
UU xxx/aaa
UU yyy/aaa
AA bbb
AA xxx/bbb
AA yyy/bbb
'
assert_files '
UU aaa		ggg0|ccc0
UU xxx/aaa	ggg1|ccc1
UU yyy/aaa	ggg2|ccc2
AA bbb		eee3|ccc3
AA xxx/bbb	eee4|ccc4
AA yyy/bbb	eee5|ccc5
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Quit $APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
cd xxx
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$APPLY_OPERATION" $COLOR_FLAGS "$QUIT_FLAG"
cd -
assert_outputs__apply__quit "$APPLY_OPERATION"
assert_files '
UU aaa		ggg0|ccc0
UU xxx/aaa	ggg1|ccc1
UU yyy/aaa	ggg2|ccc2
AA bbb		eee3|ccc3
AA xxx/bbb	eee4|ccc4
AA yyy/bbb	eee5|ccc5
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_head_sha_HT "$correct_head_sha"
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents_for 'none'
