. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'

exit 0  #TODO the test is disabled because `git stash` has a bug(?) and doesn't create the stash correctly in this case

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >bbb
git add bbb
rm bbb
git stash push

SWITCH_HEAD_TYPE

__test_section__ 'Apply stash'
correct_head_hash="$(get_head_hash_H)"
assert_exit_code 0 git istash apply
assert_files_H '
   aaa		aaa
AD bbb			bbb
!! ignored	ignored
'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_data_files 'none'
assert_rebase n
