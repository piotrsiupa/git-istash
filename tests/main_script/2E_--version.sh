. "$(dirname "$0")/../commons.sh" 1>/dev/null

# The output for every subcommand is the same as for the main script, btw.
PARAMETRIZE_SUBCOMMAND
PARAMETRIZE_COLOR
PARAMETRIZE_OPTION true 'VERSION_FLAG' '' 'version: -V && --version && --vers & --v'

__end_of_initialization__

prepare_repository

__test_section__ "Show version for subcommand \"$SUBCOMMAND\""
#shellcheck disable=SC2086
assert_exit_code 0 git istash $SUBCOMMAND $COLOR_FLAGS "$VERSION_FLAG"
assert_outputs__main_script__version
