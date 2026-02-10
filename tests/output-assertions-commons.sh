#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_outputs__too_many_arguments() { # operation
	assert_outputs_with_color '
	' '
		\[31merror: too many arguments\[0?m\n
		hint: type '\''git istash '"$1"' --help'\'' for detailed information\n
		hint: or '\''git istash '"$1"' -h'\'' for a short help text
	'
}

assert_outputs__operation_in_progress() { # operation
	assert_outputs_with_color '
	' '
		\[31merror: there is currently '\''git '"$(sanitize_for_sed "$1")"\'' in progress\[0?m\n
		hint: use '\''git istash --continue'\'' or '\''git istash --abort'\''
	'
}

assert_outputs__external_operation_in_progress() { # operation
	assert_outputs_with_color '
	' '
		\[31merror: there is currently '\''git '"$(sanitize_for_sed "$1")"\'' in progress\[0?m\n
		hint: finalize it before running '\''git istash'\''
	'
}

create_broken_operation_header_regex() { # broken_op
	printf '%s' '
		\[1;31mfatal: '\''git istash '"$1"\'' seems to be in progress but the data files are broken\[0?m
	'
}

create_broken_operation_hint_regex() {
	printf '%s' '
		hint: fix the problem and finalize that operation before starting a new one\n
		hint: or run '\''git istash --quit'\'' to forcefully cancel it
	'
}

assert_outputs__missing_data_file() { # broken_op data_file [second_data_file]
	assert_outputs_with_color '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		'"$(if [ $# -eq 2 ]
		then
			printf '%s' '\[1;31mfatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' is missing\[0?m'
		else
			printf '%s' '\[1;31mfatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' and '\''\.git\/'"$(sanitize_for_sed "$3")"\'' are missing\[0?m'
		fi)"'\n
		'"$(create_broken_operation_hint_regex)"'
	'
}
