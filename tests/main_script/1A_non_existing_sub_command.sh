. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_COLOR
PARAMETRIZE_QUIET
PARAMETRIZE_HINT 'istashImplPushPathspec'

__end_of_initialization__

prepare_repository

correct_head_sha="$(get_head_sha)"

__test_section__ "Add some files"
printf 'aaa\n' >aaa
git add aaa
printf 'aaa\n' >bbb
git add -N bbb
printf 'bbb\n' >aaa
printf 'ddd\n' >ddd

#shellcheck disable=SC2086
assert_exit_code 1 git $ADVICE_FLAGS istash $QUIET_FLAGS $COLOR_FLAGS asdf
assert_outputs__main_script__no_such_command 'asdf'
assert_files '
AM aaa		bbb	aaa
 A bbb		aaa
?? ddd		ddd
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata
assert_dotgit_contents
