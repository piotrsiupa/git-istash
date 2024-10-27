#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


. ./utils-commons.sh
. ./utils-parametrization.sh
case "$(basename "$(dirname "$OLDPWD")")" in
	applying) . ./utils-for-applying.sh ;;
	creating) . ./utils-for-creating.sh ;;
esac
