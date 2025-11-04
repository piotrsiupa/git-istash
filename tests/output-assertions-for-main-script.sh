#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_outputs__main_script__no_such_command() { # command
	assert_outputs '
	' '
		git-istash: "'"$(sanitize_for_sed "$1")"'" is not a sub-command\. See "git istash --help"\.
	'
}

assert_outputs__main_script__unrecognised_option() { # option
	assert_outputs '
	' '
		git-istash-push: unrecognized option:? '\''?(--)?'"$(sanitize_for_sed "$1")"\''?
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

assert_outputs__main_script__missing_arg_separator() { # token
	assert_outputs '
	' '
		fatal: unexpected token "'"$(sanitize_for_sed "$1")"'"\n
		fatal: pathspec for an implicit "push" command must be preceded by "--"
	'
}

assert_outputs__main_script__no_operation_in_progress() {
	assert_outputs '
	' '
		fatal: There doesn'\''t seem to be any operation in progress\.
	'
}

assert_outputs__main_script__damaged_operation_in_progress() {
	assert_outputs '
	' '
		fatal: The operation in progress seems damaged\.
	'
}
