#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# It calls "PARAMETRIZE" with the name "APPLY_OPERATION" and values "apply" & "pop".
# It also creates a variable "CAP_APPLY_OPERATION" which stores the same operation name but capitalized and a few other variables.
# (See also assertions with suffix "_O".)
PARAMETRIZE_APPLY_OPERATION() {
	PARAMETRIZE 'APPLY_OPERATION' 'apply' 'pop'
	#shellcheck disable=SC2034
	case "$APPLY_OPERATION" in
		apply)
			CAP_APPLY_OPERATION='Apply'
			OTHER_APPLY_OPERATION='pop'
			CAP_OTHER_APPLY_OPERATION='Pop'
			;;
		pop)
			CAP_APPLY_OPERATION='Pop'
			OTHER_APPLY_OPERATION='apply'
			CAP_OTHER_APPLY_OPERATION='Apply'
			;;
	esac
}
IS_APPLY() {
	test "$APPLY_OPERATION" = 'apply'
}
IS_POP() {
	test "$APPLY_OPERATION" = 'pop'
}
