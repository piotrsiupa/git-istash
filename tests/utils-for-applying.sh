#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# It calls "PARAMETRIZE" with the name "APPLY_OPERATION", the facet "subcommand" and values "apply" & "pop".
# It also creates a variable "CAP_APPLY_OPERATION" which stores the same operation name but capitalized and a few other variables.
# (See also assertions with suffix "_AO".)
PARAMETRIZE_APPLY_OPERATION() { # keys
	if [ $# -eq 0 ]
	then
		set -- 'apply' 'pop'
	fi
	PARAMETRIZE 'APPLY_OPERATION' 'subcommand' "$@"
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
PARAMETRIZE_CONTINUE() { # keys
	PARAMETRIZE_OPTION true 'CONTINUE' '' 'CONTINUE: CONTINUE-SHORT && CONTINUE-LONG && CONTINUE-LONGISH0 & CONTINUE-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$CONTINUE" in
		CONTINUE-SHORT) CONTINUE_FLAG='-c' ;;
		CONTINUE-LONG) CONTINUE_FLAG='--continue' ;;
		CONTINUE-LONGISH0) CONTINUE_FLAG='--conti' ;;
		CONTINUE-LONGISH1) CONTINUE_FLAG='--con' ;;
	esac
}

#shellcheck disable=SC2120
PARAMETRIZE_ABORT() { # keys
	PARAMETRIZE_OPTION true 'ABORT' '' 'ABORT: && ABORT-LONG && ABORT-LONGISH0 & ABORT-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$ABORT" in
		ABORT-LONG) ABORT_FLAG='--abort' ;;
		ABORT-LONGISH0) ABORT_FLAG='--abor' ;;
		ABORT-LONGISH1) ABORT_FLAG='--ab' ;;
	esac
}

#shellcheck disable=SC2120
PARAMETRIZE_QUIT() { # keys
	PARAMETRIZE_OPTION true 'QUIT' '' 'QUIT: && QUIT-LONG &&' "$@"
	#shellcheck disable=SC2034
	case "$QUIT" in
		QUIT-LONG) QUIT_FLAG='--quit' ;;
	esac
}

#shellcheck disable=SC2120
PARAMETRIZE_SUMMARY() { # keys
	PARAMETRIZE_OPTION true 'SUMMARY' 'summary' 'COMPL: && SUM-DEFAULT & SUM-COMPL-LONG && SUM-COMPL-LONGISH0 & SUM-COMPL-LONGISH2 | NON-IGNORED: && SUM-NON-IGN-LONG && SUM-NON-IGN-LONGINSH0 & SUM-NON-IGN-LONGINS1 | NO: && SUM-NO-LONG && SUM-NO-LONGISH0 & SUM-NO-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$SUMMARY" in
		SUM-DEFAULT) SUMMARY_FLAGS='' ;;
		SUM-COMPL-LONG) SUMMARY_FLAGS='--summary=complete' ;;
		SUM-COMPL-LONGISH0) SUMMARY_FLAGS='--summ compl' ;;
		SUM-COMPL-LONGISH2) SUMMARY_FLAGS='--sum=y' ;;
		SUM-NON-IGN-LONG) SUMMARY_FLAGS='--summary=non-ignored-only' ;;
		SUM-NON-IGN-LONGINSH0) SUMMARY_FLAGS='--summ no-ignor' ;;
		SUM-NON-IGN-LONGINS1) SUMMARY_FLAGS='--sum=without-ign' ;;
		SUM-NO-LONG) SUMMARY_FLAGS='--summary=off' ;;
		SUM-NO-LONGISH0) SUMMARY_FLAGS='--summ none' ;;
		SUM-NO-LONGISH1) SUMMARY_FLAGS='--sum=nope' ;;
	esac
}
IS_SUMMARY_COMPL() {
	printf '%s' "$SUMMARY" | grep -E -q '^SUM-(DEFAULT$|COMPL-)'
}
IS_SUMMARY_NON_IGNORED() {
	printf '%s' "$SUMMARY" | grep -E -q '^SUM-NON-IGN-'
}
IS_SUMMARY_ON() {
	! printf '%s' "$SUMMARY" | grep -E -q '^SUM-NO-'
}
