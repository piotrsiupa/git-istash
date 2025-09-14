# This only checks if the documentation is displayed, not it's contents.
# Always validate you're documentation manually.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'Editing PATH doesn'\''t seem to work on Windows for some reason.'
fi

PARAMETRIZE_SUBCOMMAND


__test_section__ "Displaying manual with \"$SUBCOMMAND --help\""
printf '%s\n' '#/usr/bin/env sh' 'cd "$(dirname "$0")" || exit' 'printf '\''"%s"\n'\'' "$@" >'\''./call-to-man.txt'\' >'./man'
chmod +x './man'
PATH="$(pwd):$PATH"
export PATH
assert_exit_code 0 git istash "$SUBCOMMAND" --help
test -f './call-to-man.txt' ||
	fail '"man" was not called!\n'
test "$(cat './call-to-man.txt')" = '"git-istash"' ||
	fail '"man" was called with arguments "%s" instead of "%s"!\n' "$(cat './call-to-man.txt' | tr -d '"' | tr '\n' ' ' | sed 's/ $//')" 'git-istash'
