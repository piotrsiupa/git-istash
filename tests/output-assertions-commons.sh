#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_outputs__too_many_arguments() { # operation
	assert_outputs_with_color '
	' '
		\[<color>31merror: too many arguments\[<color>0?m\n
		\[<color>33mhint: type '\''git istash '"$1"' --help'\'' for detailed information\[<color>0?m\n
		\[<color>33mhint: or '\''git istash '"$1"' -h'\'' for a short help text\[<color>0?m
	'
}

assert_outputs__operation_in_progress() { # operation
	assert_outputs_with_color '
	' '
		\[<color>31merror: there is currently '\''git '"$(sanitize_for_sed "$1")"\'' in progress\[<color>0?m\n
		\[<color>33mhint: use '\''git istash --continue'\'' or '\''git istash --abort'\''\[<color>0?m
	'
}

assert_outputs__external_operation_in_progress() { # operation
	assert_outputs_with_color '
	' '
		\[<color>31merror: there is currently '\''git '"$(sanitize_for_sed "$1")"\'' in progress\[<color>0?m\n
		\[<color>33mhint: finalize it before running '\''git istash'\''\[<color>0?m
	'
}

create_broken_operation_header_regex() { # broken_op
	printf '%s' '
		\[<color>1;31mfatal: '\''git istash '"$1"\'' seems to be in progress but the data files are broken\[<color>0?m
	'
}

create_broken_operation_hint_regex() {
	printf '%s' '
		\[<color>33mhint: fix the problem and finalize that operation before starting a new one\[<color>0?m\n
		\[<color>33mhint: or run '\''git istash --quit'\'' to forcefully cancel it\[<color>0?m
	'
}

assert_outputs__missing_data_file() { # broken_op data_file [second_data_file]
	assert_outputs_with_color '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		'"$(if [ $# -eq 2 ]
		then
			printf '%s' '\[<color>1;31mfatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' is missing\[<color>0?m'
		else
			printf '%s' '\[<color>1;31mfatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' and '\''\.git\/'"$(sanitize_for_sed "$3")"\'' are missing\[<color>0?m'
		fi)"'\n
		'"$(create_broken_operation_hint_regex)"'
	'
}
