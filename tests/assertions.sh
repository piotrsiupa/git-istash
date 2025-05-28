#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


. ./assertions-commons.sh
case "$(basename "$(dirname "$(dirname "$OLDPWD")")")" in
	applying) . ./assertions-for-applying.sh ;;
	creating) . ./assertions-for-creating.sh ;;
esac
