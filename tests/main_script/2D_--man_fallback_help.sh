# These are only a few rudimentary checks for things that are the easiest to forgot / mess up.
# Always validate you're documentation manually.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'Editing PATH doesn'\''t seem to work on Windows for some reason.'
fi

PARAMETRIZE_SUBCOMMAND
PARAMETRIZE_COLOR
PARAMETRIZE_OPTION true 'MAN_FLAG' '' 'man: && --man && --ma & --m'

__end_of_initialization__

prepare_repository


__test_section__ "Displaying manual with \"$SUBCOMMAND $MAN_FLAG\""
#shellcheck disable=SC2016
printf '%s\n' '#/usr/bin/env sh' \
	'return 1' \
	>'./man'
chmod +x './man'
PATH="$(pwd):$PATH"
export PATH
#shellcheck disable=SC2086
assert_exit_code 0 git istash $SUBCOMMAND $COLOR_FLAGS "$MAN_FLAG"
# These assertions are copied from the test for "-h".
if [ "$SUBCOMMAND" = 'c' ] || [ "$SUBCOMMAND" = 'continue' ] || [ "$SUBCOMMAND" = 'abort' ] || [ "$SUBCOMMAND" = 'quit' ]
then
	SUBCOMMAND=''
fi
assert_outputs__main_script__help y
