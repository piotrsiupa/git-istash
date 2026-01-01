#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_outputs__too_many_arguments() { # operation
	assert_outputs '
	' '
		error: too many arguments\n
		hint: type '\''git istash '"$1"' --help'\'' for detailed information\n
		hint: or '\''git istash '"$1"' -h'\'' for a short help text
	'
}
