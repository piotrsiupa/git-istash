. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'ORPHAN'

rm -rf .git
git init
printf 'ignored\n' >>.git/info/exclude

SWITCH_HEAD_TYPE

assert_exit_code 1 git istash apply
assert_files_H '
!! ignored	ignored
'
assert_stash_count 0
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n

printf 'aaa\n' >aaa
git add aaa
printf 'bbb\n' >aaa
assert_exit_code 1 git istash apply
assert_files_H '
AM aaa		bbb	aaa
!! ignored	ignored
'
assert_stash_count 0
assert_branch_count 0
assert_head_name_H
assert_data_files 'none'
assert_rebase n
