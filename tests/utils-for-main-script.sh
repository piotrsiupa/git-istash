#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


PARAMETRIZE_SUBCOMMAND() {
	PARAMETRIZE 'SUBCOMMAND' '_NONE_' 'apply' 'create' 'pop' 'push' 'save' 'snatch'
	if [ "$SUBCOMMAND" = '_NONE_' ]
	then
		SUBCOMMAND=''
	fi
}
