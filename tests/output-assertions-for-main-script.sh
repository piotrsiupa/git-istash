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
		error: (unrecognized|invalid) option:? (-- )?'\''?'"$(sanitize_for_sed "$1")"\''?
	'
}

assert_outputs__main_script__unrecognised_long_option() { # option
	assert_outputs '
	' '
		error: unrecognized option:? '\''?(--)?'"$(sanitize_for_sed "$1")"\''?
	'
}

assert_outputs__main_script__help() {
	assert_outputs '
		.{20,}+\n
		\n
		Usage: .+\n
		\n
		Options:\n.+
		(\n\n.+)?
	' '
	'
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
