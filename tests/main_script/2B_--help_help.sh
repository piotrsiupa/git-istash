# This only checks if the documentation is displayed, not it's contents.
# Always validate you're documentation manually.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'Editing PATH doesn'\''t seem to work on Windows for some reason.'
fi

PARAMETRIZE_SUBCOMMAND
PARAMETRIZE_COLOR YES
PARAMETRIZE_OPTION true 'HELP_FLAG' '' 'help: && --help && --hel & --h'

__end_of_initialization__

prepare_repository


__test_section__ "Displaying manual with \"$SUBCOMMAND $HELP_FLAG\""
#shellcheck disable=SC2016
printf '%s\n' '#/usr/bin/env sh' \
	'' \
	'cd "$(dirname "$0")" || exit' \
	'if [ "$OLDPWD" != "$(dirname "$0")" ]' \
	'then' \
	'	printf "Not called by Git!\n" >./error.txt' \
	'fi' \
	'printf '\''"%s"\n'\'' "$@" >'\''./call-to-man.txt'\' \
	>'./man'
chmod +x './man'
PATH="$(pwd):$PATH"
export PATH
#shellcheck disable=SC2086
assert_exit_code 0 git -c help.format=man -c man.mock_man.cmd="$(pwd)/man" -c man.viewer=mock_man istash $COLOR_FLAGS $SUBCOMMAND "$HELP_FLAG"
! test -f './error.txt' ||
	fail '%s\n' "$(cat './error.txt')"
test -f './call-to-man.txt' ||
	fail '"man" was not called!\n'
test "$(cat './call-to-man.txt')" = '"git-istash"' ||
	fail '"man" was called with arguments "%s" instead of "%s"!\n' "$(tr -d '"' <'./call-to-man.txt' | tr '\n' ' ' | sed 's/ $//')" 'git-istash'
