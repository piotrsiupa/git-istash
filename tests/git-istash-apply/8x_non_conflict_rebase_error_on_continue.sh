. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ccc\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

assert_exit_code 2 capture_outputs git istash apply
assert_conflict_message git istash apply
assert_files_H '
UU aaa		ccc|bbb
!! ignored	ignored
' '
DU aaa		bbb
!! ignored	ignored
'
assert_stash_count 1
assert_data_files 'apply'
assert_rebase y

printf 'ddd\n' >aaa
git add aaa
rm -rf '.git/rebase-apply' '.git/rebase-merge'
assert_exit_code 1 git istash apply --continue
assert_files_H '
M  aaa		ddd
!! ignored	ignored
' '
A  aaa		ddd
!! ignored	ignored
'
assert_stash_count 1
assert_head_name 'HEAD'
assert_data_files 'apply'
assert_rebase n
