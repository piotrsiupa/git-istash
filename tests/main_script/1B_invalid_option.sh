# This checks if the error message is passed to the user correctly rather that checking the argument validation in general.
# That's why there are no tests for other kind of errors here. (They are all handled in unit tests.)

. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_SUBCOMMAND
if [ "$SUBCOMMAND" = 'c' ] || [ "$SUBCOMMAND" = 'continue' ] || [ "$SUBCOMMAND" = 'abort' ] || [ "$SUBCOMMAND" = 'quit' ]
then
	skip_silently
fi
PARAMETRIZE_COLOR

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

__test_section__ "Call \"$SUBCOMMAND\" with an invalid short option"
#shellcheck disable=SC2086
assert_exit_code 1 git istash $SUBCOMMAND $COLOR_FLAGS -x
assert_outputs__main_script__unrecognised_short_option 'x'
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

__test_section__ "Call \"$SUBCOMMAND\" with an invalid long option"
#shellcheck disable=SC2086
assert_exit_code 1 git istash $SUBCOMMAND $COLOR_FLAGS --xxx
assert_outputs__main_script__unrecognised_long_option 'xxx'
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
