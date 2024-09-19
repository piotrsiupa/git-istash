#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# It calls "PARAMETRIZE" with the name "OPERATION" and values "apply" & "pop".
# It also creates a variable "CAP_OPERATION" which stores the same operation name but capitalized.
# (See also assertions with suffix "_O".)
PARAMETRIZE_APPLY_POP() {
	PARAMETRIZE 'OPERATION' 'apply' 'pop'
	#shellcheck disable=SC2034
	case "$OPERATION" in
		apply)
			CAP_OPERATION='Apply'
			OTHER_OPERATION='pop'
			CAP_OTHER_OPERATION='Pop'
			;;
		pop)
			CAP_OPERATION='Pop'
			OTHER_OPERATION='apply'
			CAP_OTHER_OPERATION='Apply'
			;;
	esac
}
IS_APPLY() {
	test "$OPERATION" = 'apply'
}
IS_POP() {
	test "$OPERATION" = 'pop'
}
