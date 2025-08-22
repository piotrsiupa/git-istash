#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# It calls "PARAMETRIZE" with the name "APPLY_OPERATION" and values "apply" & "pop".
# It also creates a variable "CAP_APPLY_OPERATION" which stores the same operation name but capitalized and a few other variables.
# (See also assertions with suffix "_AO".)
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

#shellcheck disable=SC2120
PARAMETRIZE_ABORT() { # keys
	PARAMETRIZE_OPTION true 'ABORT' 'ABORT: ABORT-LONG && ABORT-LONGISH0 & ABORT-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$ABORT" in
		ABORT-LONG) ABORT_FLAG='--abort' ;;
		ABORT-LONGISH0) ABORT_FLAG='--abor' ;;
		ABORT-LONGISH1) ABORT_FLAG='--ab' ;;
	esac
}

#shellcheck disable=SC2120
PARAMETRIZE_CONTINUE() { # keys
	PARAMETRIZE_OPTION true 'CONTINUE' 'CONTINUE: CONTINUE-SHORT & CONTINUE-LONG && CONTINUE-LONGISH0 & CONTINUE-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$CONTINUE" in
		CONTINUE-SHORT) CONTINUE_FLAG='-c' ;;
		CONTINUE-LONG) CONTINUE_FLAG='--continue' ;;
		CONTINUE-LONGISH0) CONTINUE_FLAG='--conti' ;;
		CONTINUE-LONGISH1) CONTINUE_FLAG='--con' ;;
	esac
}
