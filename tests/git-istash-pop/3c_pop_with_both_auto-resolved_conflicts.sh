. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push

__test_section__ 'Create conflict'
printf 'bbb\n' >aaa
git commit -am 'Changed aaa'

SWITCH_HEAD_TYPE

__test_section__ 'Pop stash'
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash pop
assert_files_H '
 M aaa		ccc	bbb
!! ignored	ignored
'
assert_stash_count 0
assert_log_length_H 3
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
