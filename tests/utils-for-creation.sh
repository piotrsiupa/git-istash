#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


PARAMETRIZE_KEEP_INDEX() {
	PARAMETRIZE 'KEEP_INDEX' 'INDEX-DEFAULT' 'INDEX-NO-LONG' 'INDEX-YES-SHORT' 'INDEX-YES-LONG'
	#shellcheck disable=SC2034
	case "$KEEP_INDEX" in
		INDEX-DEFAULT) KEEP_INDEX_FLAGS='' ;;
		INDEX-NO-LONG) KEEP_INDEX_FLAGS='--no-keep-index' ;;
		INDEX-YES-SHORT) KEEP_INDEX_FLAGS='-k' ;;
		INDEX-YES-LONG) KEEP_INDEX_FLAGS='--keep-index' ;;
	esac
}
IS_KEEP_INDEX_ON() {
	printf '%s' "$KEEP_INDEX" | grep -Eq '^INDEX-YES-'
}
IS_KEEP_INDEX_OFF() {
	printf '%s' "$KEEP_INDEX" | grep -Eq '^INDEX-NO-'
}

PARAMETRIZE_OPTIONS_INDICATOR() { # condition
	PARAMETRIZE_COND "$1" 'END_OPTIONS_INDICATOR' 'EOI-NO' 'EOI-YES'
	#shellcheck disable=SC2034
	case "$END_OPTIONS_INDICATOR" in
		'EOI-NO') EOI='' ;;
		'EOI-YES') EOI='--' ;;
	esac
}
IS_OPTIONS_INDICATOR_ON() {
	test "$END_OPTIONS_INDICATOR" = 'EOI-YES'
}
IS_OPTIONS_INDICATOR_OFF() {
	test "$END_OPTIONS_INDICATOR" = 'EOI-NO'
}

PARAMETRIZE_PATHSPEC_STYLE() {
	PARAMETRIZE 'PATHSPEC' 'PS-ARGS' 'PS-STDIN' 'PS-NULL-STDIN' 'PS-FILE' 'PS-NULL-FILE'
	#shellcheck disable=SC2034
	if ! IS_PATHSPEC_NULL_SEP
	then
		PATHSPEC_NULL_FLAG=''
	else
		PATHSPEC_NULL_FLAG='--pathspec-file-nul'
	fi
}
IS_PATHSPEC_IN_ARGS() {
	test "$PATHSPEC" = 'PS-ARGS'
}
IS_PATHSPEC_IN_STDIN() {
	printf '%s' "$PATHSPEC" | grep -qE -- '-STDIN$'
}
IS_PATHSPEC_IN_FILE() {
	printf '%s' "$PATHSPEC" | grep -qE -- '-FILE$'
}
IS_PATHSPEC_NULL_SEP() {
	printf '%s' "$PATHSPEC" | grep -qE -- '-NULL-'
}
