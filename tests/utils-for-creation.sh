#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# It calls "PARAMETRIZE" with the name "KEEP_INDEX" and values "DEFAULT", "NO-LONG", "YES-SHORT" & "YES-LONG".
# It also creates a variable "KEEP_INDEX_FLAGS" which should be added to "istash" commands creating stashes (not quoted).
# (See also functions below.)
PARAMETRIZE_KEEP_INDEX() {
	PARAMETRIZE 'KEEP_INDEX' 'DEFAULT' 'NO-LONG' 'YES-SHORT' 'YES-LONG'
	#shellcheck disable=SC2034
	case "$KEEP_INDEX" in
		DEFAULT) KEEP_INDEX_FLAGS='' ;;
		NO-LONG) KEEP_INDEX_FLAGS='--no-keep-index' ;;
		YES-SHORT) KEEP_INDEX_FLAGS='-k' ;;
		YES-LONG) KEEP_INDEX_FLAGS='--keep-index' ;;
	esac
}
IS_KEEP_INDEX_ON() {
	printf '%s' "$KEEP_INDEX" | grep -Eq '^YES-'
}
IS_KEEP_INDEX_OFF() {
	printf '%s' "$KEEP_INDEX" | grep -Eq '^NO-'
}
