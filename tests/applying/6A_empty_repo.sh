. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'ORPHAN'
PARAMETRIZE_APPLY_POP

__test_section__ 'Prepare repository'
rm -rf .git
git init
mkdir -p .git/info
printf 'ignored?\0n' >>.git/info/exclude

SWITCH_HEAD_TYPE

__test_section__ "$CAP_OPERATION stash (without changes)"
assert_exit_code 1 git istash "$OPERATION"
assert_files_H '
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents

__test_section__ "$CAP_OPERATION stash (with changes)"
printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
assert_exit_code 1 git istash "$OPERATION"
assert_files_H '
AM aaa		bbb	aaa
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_branch_count 0
assert_head_name_H
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
