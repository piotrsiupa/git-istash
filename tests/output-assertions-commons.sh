#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_outputs__too_many_arguments() { # operation
	assert_outputs '
	' '
		error: Too many arguments\.\n
		error: Type "git istash '"$1"' --help" for more information\.
	'
}
