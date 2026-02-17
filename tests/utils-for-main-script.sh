#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


PARAMETRIZE_SUBCOMMAND() {
	PARAMETRIZE 'SUBCOMMAND' 'subcommand' '_NONE_' 'apply' 'create' 'pop' 'push' 'save' 'snatch' 'c' 'continue' 'abort' 'quit'
	if [ "$SUBCOMMAND" = '_NONE_' ]
	then
		SUBCOMMAND=''
	fi
}
