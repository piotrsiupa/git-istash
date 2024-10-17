#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


#shellcheck disable=SC2120
PARAMETRIZE_KEEP_INDEX() { # keys
	PARAMETRIZE_OPTION true 'KEEP_INDEX' 'DEFAULT: INDEX-DEFAULT | NO: INDEX-NO-LONG && INDEX-NO-LONGISH0 & INDEX-NO-LONGISH1 | YES: INDEX-YES-SHORT & INDEX-YES-LONG && INDEX-YES-LONGISH0 & INDEX-YES-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$KEEP_INDEX" in
		INDEX-DEFAULT) KEEP_INDEX_FLAGS='' ;;
		INDEX-NO-LONG) KEEP_INDEX_FLAGS='--no-keep-index' ;;
		INDEX-NO-LONGISH0) KEEP_INDEX_FLAGS='--no-keep-ind' ;;
		INDEX-NO-LONGISH1) KEEP_INDEX_FLAGS='--no-keep' ;;
		INDEX-YES-SHORT) KEEP_INDEX_FLAGS='-k' ;;
		INDEX-YES-LONG) KEEP_INDEX_FLAGS='--keep-index' ;;
		INDEX-YES-LONGISH0) KEEP_INDEX_FLAGS='--keep-i' ;;
		INDEX-YES-LONGISH1) KEEP_INDEX_FLAGS='--kee' ;;
	esac
}
IS_KEEP_INDEX_ON() {
	printf '%s' "$KEEP_INDEX" | grep -Eq '^INDEX-YES-'
}
IS_KEEP_INDEX_OFF() {
	printf '%s' "$KEEP_INDEX" | grep -Eq '^INDEX-NO-'
}

PARAMETRIZE_ALL() { # keys
	PARAMETRIZE_OPTION true 'ALL' 'DEFAULT: ALL-DEFAULT | YES: ALL-YES-SHORT & ALL-YES-LONG && ALL-YES-LONGISH0 & ALL-YES-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$ALL" in
		ALL-DEFAULT) ALL_FLAGS='' ;;
		ALL-YES-SHORT) ALL_FLAGS='-a' ;;
		ALL-YES-LONG) ALL_FLAGS='--all' ;;
		ALL-YES-LONGISH0) ALL_FLAGS='--al' ;;
		ALL-YES-LONGISH1) ALL_FLAGS='--a' ;;
	esac
}
IS_ALL_ON() {
	printf '%s' "$ALL" | grep -Eq '^ALL-YES-'
}

PARAMETRIZE_UNTRACKED() { # keys
	PARAMETRIZE_OPTION true 'UNTRACKED' 'DEFAULT: UNTR-DEFAULT | NO: UNTR-NO-LONG && UNTR-NO-LONGISH0 & UNTR-NO-LONGISH1 | YES: UNTR-YES-SHORT & UNTR-YES-LONG && UNTR-YES-LONGISH0 & UNTR-YES-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$UNTRACKED" in
		UNTR-DEFAULT) UNTRACKED_FLAGS='' ;;
		UNTR-NO-LONG) UNTRACKED_FLAGS='--no-include-untracked' ;;
		UNTR-NO-LONGISH0) UNTRACKED_FLAGS='--no-include-untr' ;;
		UNTR-NO-LONGISH1) UNTRACKED_FLAGS='--no-inc' ;;
		UNTR-YES-SHORT) UNTRACKED_FLAGS='-u' ;;
		UNTR-YES-LONG) UNTRACKED_FLAGS='--include-untracked' ;;
		UNTR-YES-LONGISH0) UNTRACKED_FLAGS='--include-u' ;;
		UNTR-YES-LONGISH1) UNTRACKED_FLAGS='--incl' ;;
	esac
}
IS_UNTRACKED_ON() {
	printf '%s' "$UNTRACKED" | grep -Eq '^UNTR-YES-'
}
IS_UNTRACKED_OFF() {
	printf '%s' "$UNTRACKED" | grep -Eq '^UNTR-NO-'
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
	#shellcheck disable=SC2154
	if [ "$meticulousness" -gt 2 ]
	then
		PARAMETRIZE 'PATHSPEC' 'PS-ARGS' 'PS-STDIN' 'PS-NULL-STDIN' 'PS-FILE' 'PS-NULL-FILE'
	else
		PARAMETRIZE 'PATHSPEC' 'PS-ARGS' 'PS-STDIN' 'PS-NULL-FILE'
	fi
	#shellcheck disable=SC2034
	if ! IS_PATHSPEC_NULL_SEP
	then
		PATHSPEC_NULL_FLAGS=''
	else
		PATHSPEC_NULL_FLAGS='--pathspec-file-nul'
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
