#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_outputs__main_script__no_such_command() { # command
	assert_outputs '
	' '
		error: subcommand wasn'\''t specified; '\''push'\'' can'\''t be assumed due to unexpected token '\'"$(sanitize_for_sed "$1")"\''\n
		hint: pathspecs for an implicit '\''push'\'' subcommand must be preceded by '\''--'\''
	'
}

assert_outputs__main_script__unrecognised_short_option() { # option
	# "getopt" doesn't give a very consistent output between inplementations
	assert_outputs '
	' '
		error: unknown switch `'"$(sanitize_for_sed "$1")"\''
	'
}

assert_outputs__main_script__unrecognised_long_option() { # option
	assert_outputs '
	' '
		error: unknown option `'"$(sanitize_for_sed "$1")"\''
	'
}

assert_outputs__main_script__help() { # [is_fallback]
	assert_outputs_with_color '
		.{20,}+\n
		\n
		Usage: .+\n
		\n
		Options:\n.+
		(\n\n.+)?
	' "$(
		if [ "${1-n}" = y ]
		then
			printf '%s' '\[1;31mfatal: unable to open the manual entry\[0?m\n'
			printf '%s' '\[1;31mfatal: falling back to the built-in help text\[0?m'
		fi
	)"
	#shellcheck disable=SC2154
	mentions_of_this_subcommand="$(printf '%s\n' "$stdout" | grep -Fc "git istash $SUBCOMMAND" || true)"
	mentions_of_any_subcommand="$(printf '%s\n' "$stdout" | grep -Ec 'git istash \w+' || true)"
	test "$mentions_of_this_subcommand" -ge 1 ||
		fail 'The "-h" help is not for the subcommand "%s"!\n' "$SUBCOMMAND"
	test "$mentions_of_this_subcommand" -ge "$mentions_of_any_subcommand" ||
		fail 'Other subcommands are mentioned in the "-h" help. (Did you copy it form other file?)\n'  # Not a real bug but currently the condition is fulfilled for all commands and this check will help to catch developer errors.
	usage_line_regex="^Usage: git istash $SUBCOMMAND"
	printf '%s\n' "$stdout" | grep -Eq "$usage_line_regex" ||
		fail 'The "-h" help doesn'\''t have a "usage" line!\n'
	printf '%s\n' "$stdout" | tail -n +3 | grep -Eq "$usage_line_regex" ||
		fail 'The "-h" help starts with the "usage" line!\n(There should be a short description.)\n'
	printf '%s\n' "$stdout" | grep -Fxq 'Options:' ||
		fail 'The "-h" help doesn'\''t have an "options" section!\n'
}

assert_outputs__main_script__version() {
	assert_outputs '
		git-istash version [1-9][0-9]*\.([1-9][0-9]*|0)\.([1-9][0-9]*|0)\n
		Author: Piotr Siupa\n
		Requires Git in version at least [1-9][0-9]*\.([1-9][0-9]*|0)\.([1-9][0-9]*|0)
	' '
	'
}

assert_outputs__main_script__no_operation_in_progress() {
	assert_outputs '
	' '
		error: no istash operation in progress
	'
}
