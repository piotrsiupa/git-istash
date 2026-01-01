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

assert_outputs__main_script__missing_arg_separator() { # token
	# This call the other assertion because output should be the same in this case.
	# This is a slightly different situation, though, so the separate function is kept just in case.
	assert_outputs__main_script__no_such_command "$@"
}

assert_outputs__main_script__unrecognised_option() { # option
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

assert_outputs__main_script__no_operation_in_progress() {
	assert_outputs '
	' '
		error: no istash operation in progress
	'
}

assert_outputs__main_script__damaged_operation_in_progress() {
	assert_outputs '
	' '
		fatal: the operation in progress seems to be broken
	'
}
