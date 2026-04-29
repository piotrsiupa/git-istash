# These are only a few rudimentary checks for things that are the easiest to forgot / mess up.
# Always validate you're documentation manually.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_SUBCOMMAND
PARAMETRIZE_COLOR
PARAMETRIZE_QUIET

__end_of_initialization__

prepare_repository

__test_section__ "Show short help for subcommand \"$SUBCOMMAND\""
#shellcheck disable=SC2086
assert_exit_code 0 git istash $QUIET_FLAGS $SUBCOMMAND $COLOR_FLAGS -h
if [ "$SUBCOMMAND" = 'c' ] || [ "$SUBCOMMAND" = 'continue' ] || [ "$SUBCOMMAND" = 'abort' ] || [ "$SUBCOMMAND" = 'quit' ]
then
	SUBCOMMAND=''
fi
assert_outputs__main_script__help n
