#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# It calls "PARAMETRIZE" with the name "CREATE_OPERATION", the facet "subcommand" and values "create" & "push".
# It also creates a variable "CAP_CREATE_OPERATION" which stores the same operation name but capitalized.
# (See also assertions with suffix "_O".)
#shellcheck disable=SC2120
PARAMETRIZE_CREATE_OPERATION() { # [operations...]
	if [ $# -eq 0 ]
	then
		PARAMETRIZE 'CREATE_OPERATION' 'subcommand' 'create' 'snatch' 'save' 'push'
	else
		PARAMETRIZE 'CREATE_OPERATION' 'subcommand' "$@"
	fi
	#shellcheck disable=SC2034
	CAP_CREATE_OPERATION="$(printf '%s' "$CREATE_OPERATION" | head -c1 | tr '[:lower:]' '[:upper:]')${CREATE_OPERATION#?}"
}
IS_CREATE() {
	test "$CREATE_OPERATION" = 'create'
}
IS_SNATCH() {
	test "$CREATE_OPERATION" = 'snatch'
}
IS_SAVE() {
	test "$CREATE_OPERATION" = 'save'
}
IS_PUSH() {
	test "$CREATE_OPERATION" = 'push'
}
CO_REMOVES_FILES() {
	IS_SNATCH || IS_PUSH
}
CO_STORES_STASH() {
	IS_SAVE || IS_PUSH
}


#shellcheck disable=SC2120
PARAMETRIZE_KEEP_INDEX() { # keys
	PARAMETRIZE_OPTION true 'KEEP_INDEX' '' 'DEFAULT: && INDEX-DEFAULT && | NO: && INDEX-NO-LONG && INDEX-NO-LONGISH0 & INDEX-NO-LONGISH1 | YES: INDEX-YES-SHORT && INDEX-YES-LONG && INDEX-YES-LONGISH0 & INDEX-YES-LONGISH1' "$@"
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
	case "${KEEP_INDEX-'INDEX-DEFAULT'}" in
		INDEX-YES-*)	return 0 ;;
		*)		return 1 ;;
	esac
}
IS_KEEP_INDEX_OFF() {
	case "${KEEP_INDEX-'INDEX-DEFAULT'}" in
		INDEX-NO-*)	return 0 ;;
		*)		return 1 ;;
	esac
}


#shellcheck disable=SC2120
PARAMETRIZE_STAGED() { # keys
	PARAMETRIZE_OPTION true 'STAGED' '' 'YES: && STAGED-YES && | NO: STAGED-NO-SHORT && STAGED-NO-LONG0 & STAGED-NO-LONG1 && STAGED-NO-LONGISH0 & STAGED-NO-LONGISH1 & STAGED-NO-LONGISH2 & STAGED-NO-LONGISH3 & STAGED-NO-ALT0 & STAGED-NO-ALT1 & STAGED-NO-ALT2 & STAGED-NO-ALT3 & STAGED-NO-OLD0' "$@"
	#shellcheck disable=SC2034
	case "$STAGED" in
		STAGED-YES) STAGED_FLAGS='' ;;
		STAGED-NO-SHORT) STAGED_FLAGS='-I' ;;
		STAGED-NO-LONG0) STAGED_FLAGS='--skip-index' ;;
		STAGED-NO-LONG1) STAGED_FLAGS='--skip-staged' ;;
		STAGED-NO-LONGISH0) STAGED_FLAGS='--leave-ind' ;;
		STAGED-NO-LONGISH1) STAGED_FLAGS='--skip-i' ;;
		STAGED-NO-LONGISH2) STAGED_FLAGS='--leave-stag' ;;
		STAGED-NO-LONGISH3) STAGED_FLAGS='--skip-s' ;;
		STAGED-NO-ALT0) STAGED_FLAGS='--no-include-index' ;;
		STAGED-NO-ALT1) STAGED_FLAGS='--no-include-i' ;;
		STAGED-NO-ALT2) STAGED_FLAGS='--no-include-staged' ;;
		STAGED-NO-ALT3) STAGED_FLAGS='--no-include-s' ;;
		STAGED-NO-OLD0) STAGED_FLAGS='-l' ;;
	esac
}
IS_STAGED_ON() {
	case "${STAGED-'STAGED-YES'}" in
		STAGED-YES)	return 0 ;;
		*)		return 1 ;;
	esac
}


#shellcheck disable=SC2120
PARAMETRIZE_UNSTAGED() { # keys
	PARAMETRIZE_OPTION true 'UNSTAGED' '' 'YES: && UNSTGD-YES && | NO: UNSTGD-NO-SHORT && UNSTGD-NO-LONG0 & UNSTGD-NO-LONG1 && UNSTGD-NO-LONGISH0 & UNSTGD-NO-LONGISH1 & UNSTGD-NO-LONGISH2 & UNSTGD-NO-LONGISH3 & UNSTGD-NO-ALT0 & UNSTGD-NO-ALT1 & UNSTGD-NO-ALT2 & UNSTGD-NO-ALT3 & UNSTGD-NO-OLD0 & UNSTGD-NO-OLD1' "$@"
	#shellcheck disable=SC2034
	case "$UNSTAGED" in
		UNSTGD-YES) UNSTAGED_FLAGS='' ;;
		UNSTGD-NO-SHORT) UNSTAGED_FLAGS='-T' ;;
		UNSTGD-NO-LONG0) UNSTAGED_FLAGS='--skip-tracked' ;;
		UNSTGD-NO-LONG1) UNSTAGED_FLAGS='--skip-unstaged' ;;
		UNSTGD-NO-LONGISH0) UNSTAGED_FLAGS='--leave-trac' ;;
		UNSTGD-NO-LONGISH1) UNSTAGED_FLAGS='--skip-t' ;;
		UNSTGD-NO-LONGISH2) UNSTAGED_FLAGS='--leave-unstag' ;;
		UNSTGD-NO-LONGISH3) UNSTAGED_FLAGS='--skip-uns' ;;
		UNSTGD-NO-ALT0) UNSTAGED_FLAGS='--no-include-tracked' ;;
		UNSTGD-NO-ALT1) UNSTAGED_FLAGS='--no-include-t' ;;
		UNSTGD-NO-ALT2) UNSTAGED_FLAGS='--no-include-unstaged' ;;
		UNSTGD-NO-ALT3) UNSTAGED_FLAGS='--no-include-uns' ;;
		UNSTGD-NO-OLD0) UNSTAGED_FLAGS='-S' ;;
		UNSTGD-NO-OLD1) UNSTAGED_FLAGS='--staged' ;;
	esac
}
IS_UNSTAGED_ON() {
	case "${UNSTAGED-'UNSTGD-YES'}" in
		UNSTGD-YES)	return 0 ;;
		*)		return 1 ;;
	esac
}

#shellcheck disable=SC2120
PARAMETRIZE_ALL() { # keys
	PARAMETRIZE_OPTION true 'ALL' '' 'DEFAULT: && ALL-DEFAULT && | YES: ALL-YES-SHORT && ALL-YES-LONG &&' "$@"
	#shellcheck disable=SC2034
	case "$ALL" in
		ALL-DEFAULT) ALL_FLAGS='' ;;
		ALL-YES-SHORT) ALL_FLAGS='-a' ;;
		ALL-YES-LONG) ALL_FLAGS='--all' ;;
	esac
}
IS_ALL_ON() {
	case "${ALL-'ALL-DEFAULT'}" in
		ALL-YES-*)	return 0 ;;
		*)		return 1 ;;
	esac
}

#shellcheck disable=SC2120
PARAMETRIZE_UNTRACKED() { # keys
	PARAMETRIZE_OPTION true 'UNTRACKED' '' 'DEFAULT: && UNTR-DEFAULT && | NO: && UNTR-NO-LONG && UNTR-NO-LONGISH0 & UNTR-NO-LONGISH1 & UNTR-NO-ALT0 & UNTR-NO-ALT1 | YES: UNTR-YES-SHORT && UNTR-YES-LONG && UNTR-YES-LONGISH0 & UNTR-YES-LONGISH1 & UNTR-YES-ALT0 & UNTR-YES-ALT1' "$@"
	#shellcheck disable=SC2034
	case "$UNTRACKED" in
		UNTR-DEFAULT) UNTRACKED_FLAGS='' ;;
		UNTR-NO-LONG) UNTRACKED_FLAGS='--skip-untracked' ;;
		UNTR-NO-LONGISH0) UNTRACKED_FLAGS='--leave-untra' ;;
		UNTR-NO-LONGISH1) UNTRACKED_FLAGS='--skip-unt' ;;
		UNTR-NO-ALT0) UNTRACKED_FLAGS='--no-include-untracked' ;;
		UNTR-NO-ALT1) UNTRACKED_FLAGS='--no-include-unt' ;;
		UNTR-YES-SHORT) UNTRACKED_FLAGS='-u' ;;
		UNTR-YES-LONG) UNTRACKED_FLAGS='--untracked' ;;
		UNTR-YES-LONGISH0) UNTRACKED_FLAGS='--untrac' ;;
		UNTR-YES-LONGISH1) UNTRACKED_FLAGS='--unt' ;;
		UNTR-YES-ALT0) UNTRACKED_FLAGS='--include-untracked' ;;
		UNTR-YES-ALT1) UNTRACKED_FLAGS='--include-unt' ;;
	esac
}
IS_UNTRACKED_ON() {
	case "${UNTRACKED-'UNTR-DEFAULT'}" in
		UNTR-YES-*)	return 0 ;;
		*)		return 1 ;;
	esac
}
IS_UNTRACKED_OFF() {
	case "${UNTRACKED-'UNTR-DEFAULT'}" in
		UNTR-NO-*)	return 0 ;;
		*)		return 1 ;;
	esac
}

PARAMETRIZE_OPTIONS_INDICATOR() { # condition
	PARAMETRIZE_COND "$1" 'END_OPTIONS_INDICATOR' 'end-options-indicator' 'EOI-NO' 'EOI-YES'
	#shellcheck disable=SC2034
	case "$END_OPTIONS_INDICATOR" in
		'EOI-NO') EOI='' ;;
		'EOI-YES') EOI='--' ;;
	esac
}
IS_OPTIONS_INDICATOR_ON() {
	test "${END_OPTIONS_INDICATOR-'EIO-NO'}" = 'EOI-YES'
}
IS_OPTIONS_INDICATOR_OFF() {
	test "${END_OPTIONS_INDICATOR-'EIO-NO'}" = 'EOI-NO'
}

PARAMETRIZE_PATHSPEC_STYLE() { # keys
	#shellcheck disable=SC2154
	if is_facet_active 'full-pathspec-style'
	then
		: # leave as is
	elif is_facet_active 'pathspec-style'
	then
		if [ $# -eq 0 ]
		then
			set -- 'ARGS' 'STDIN' 'NULL-FILE'
		else
			#shellcheck disable=SC2046
			set -- $(
				printf ':%s:' "$@" \
				| sed -E -e '/:NULL-FILE:/ s/:NULL-STDIN://' -e '/:STDIN:/ s/:FILE://' \
				| tr ':' ' '
			)
		fi
	else
		if [ $# -eq 0 ]
		then
			set -- 'ARGS'
		else
			set -- "$1"
		fi
	fi
	PARAMETRIZE_OPTION true 'PATHSPEC' '(full-)?pathspec-style' 'ARGS: && PS-ARGS && | STDIN: && PS-STDIN && PS-STDIN-ISH | NULL-STDIN: && PS-NULL-STDIN && PS-NULL-STDIN-ISH | FILE: && PS-FILE && PS-FILE-ISH | NULL-FILE: && PS-NULL-FILE && PS-NULL-FILE-ISH' "$@"
	#shellcheck disable=SC2034
	if IS_PATHSPEC_IN_ARGS
	then
		PATHSPEC_FROM_FILE_FLAG=''
	elif [ "${PATHSPEC%-ISH}" = "$PATHSPEC" ]
	then
		PATHSPEC_FROM_FILE_FLAG='--pathspec-from-file'
	else
		PATHSPEC_FROM_FILE_FLAG='--pathspec-from'
	fi
	#shellcheck disable=SC2034
	if ! IS_PATHSPEC_NULL_SEP
	then
		PATHSPEC_NULL_FLAGS=''
	elif [ "${PATHSPEC%-ISH}" = "$PATHSPEC" ]
	then
		PATHSPEC_NULL_FLAGS='--pathspec-file-nul'
	else
		PATHSPEC_NULL_FLAGS='--pathspec-file-n'
	fi
}
IS_PATHSPEC_IN_ARGS() {
	test "$PATHSPEC" = 'PS-ARGS'
}
IS_PATHSPEC_IN_STDIN() {
	case "$PATHSPEC" in
		*-STDIN|*-STDIN-ISH)	return 0 ;;
		*)			return 1 ;;
	esac
}
IS_PATHSPEC_IN_FILE() {
	case "$PATHSPEC" in
		*-FILE|*-FILE-ISH)	return 0 ;;
		*)			return 1 ;;
	esac
}
IS_PATHSPEC_NULL_SEP() {
	case "$PATHSPEC" in
		*-NULL-*)	return 0 ;;
		*)		return 1 ;;
	esac
}
PREPARE_PATHSPEC_FILE() {
	if IS_PATHSPEC_NULL_SEP
	then
		tr ' ' '\0'
	else
		tr ' ' '\n'
	fi >"$(git rev-parse --git-dir)/pathspec_for_test"
}

PARAMETRIZE_EXCLUDE() {
	PARAMETRIZE_OPTION true 'EXCLUDE_STYLE' 'partial-options' 'EXCLUDE: && EXCL_LONG && EXCL_STD & EXCL_COLON & EXCL_CARET & EXCL_CARET_COLON'
	#shellcheck disable=SC2034
	case "$EXCLUDE_STYLE" in
		EXCL_LONG) EXCLUDE_PATTERN='(exclude)' ;;
		EXCL_STD) EXCLUDE_PATTERN='!' ;;
		EXCL_COLON) EXCLUDE_PATTERN='!:' ;;
		EXCL_CARET) EXCLUDE_PATTERN='^' ;;
		EXCL_CARET_COLON) EXCLUDE_PATTERN='^:' ;;
	esac
}

store_stash_CO() { # new_stash_sha
	if CO_STORES_STASH
	then
		test -z "$1" ||
			fail 'The operation "%s" should not print anything to the output!\n' "$CREATE_OPERATION"
	else
		stash_count_before="$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)"
		git stash store "$1" ||
			fail 'Cannot store stash using sha returned by "%s"! ("%s")\n' "$CREATE_OPERATION" "$1"
		stash_count_after="$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)"
		test "$stash_count_after" -gt "$stash_count_before" ||
			fail 'Storing stash produced by "%s" quietly failed! (Possibly a duplicated entry.)\n' "$CREATE_OPERATION"
		unset stash_count_before
		unset stash_count_after
	fi
}
