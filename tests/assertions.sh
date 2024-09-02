#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


category="$(basename "$(dirname "$OLDPWD")")"
. ./assertions-commons.sh
if printf '%s' "$category" | grep -xqE 'git-istash-(apply|pop)'
then
	. ./assertions-for-applying.sh
fi
if printf '%s' "$category" | grep -xqE 'git-istash-push'
then
	. ./assertions-for-creation.sh
fi
unset category
