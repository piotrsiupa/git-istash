#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# It calls "PARAMETRIZE" with the name "CREATE_OPERATION" and values "create" & "push".
# It also creates a variable "CAP_CREATE_OPERATION" which stores the same operation name but capitalized.
# (See also assertions with suffix "_O".)
#shellcheck disable=SC2120
PARAMETRIZE_CREATE_OPERATION() { # [operations...]
	if [ $# -eq 0 ]
	then
		PARAMETRIZE 'CREATE_OPERATION' 'create' 'snatch' 'save' 'push'
	else
		PARAMETRIZE 'CREATE_OPERATION' "$@"
	fi
	#shellcheck disable=SC2034
	CAP_CREATE_OPERATION="$(printf '%s' "$CREATE_OPERATION" | cut  -c1 | tr '[:lower:]' '[:upper:]')$(printf '%s' "$CREATE_OPERATION" | cut  -c2-)"
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


#shellcheck disable=SC2120
PARAMETRIZE_STAGED() { # keys
	PARAMETRIZE_OPTION true 'STAGED' 'YES: STAGED-YES | NO: STAGED-NO-SHORT & STAGED-NO-LONG && STAGED-NO-LONGISH0 & STAGED-NO-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$STAGED" in
		STAGED-YES) STAGED_FLAGS='' ;;
		STAGED-NO-SHORT) STAGED_FLAGS='-l' ;;
		STAGED-NO-LONG) STAGED_FLAGS='--leave-staged' ;;
		STAGED-NO-LONGISH0) STAGED_FLAGS='--leave-s' ;;
		STAGED-NO-LONGISH1) STAGED_FLAGS='--leav' ;;
	esac
}
IS_STAGED_ON() {
	printf '%s' "$STAGED" | grep -Eq '^STAGED-YES$'
}


#shellcheck disable=SC2120
PARAMETRIZE_UNSTAGED() { # keys
	PARAMETRIZE_OPTION true 'UNSTAGED' 'YES: UNSTGD-YES | NO: UNSTGD-NO-SHORT & UNSTGD-NO-LONG && UNSTGD-NO-LONGISH0 & UNSTGD-NO-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$UNSTAGED" in
		UNSTGD-YES) UNSTAGED_FLAGS='' ;;
		UNSTGD-NO-SHORT) UNSTAGED_FLAGS='-S' ;;
		UNSTGD-NO-LONG) UNSTAGED_FLAGS='--staged' ;;
		UNSTGD-NO-LONGISH0) UNSTAGED_FLAGS='--stag' ;;
		UNSTGD-NO-LONGISH1) UNSTAGED_FLAGS='--st' ;;
	esac
}
IS_UNSTAGED_ON() {
	printf '%s' "$UNSTAGED" | grep -Eq '^UNSTGD-YES$'
}

#shellcheck disable=SC2120
PARAMETRIZE_ALL() { # keys
	PARAMETRIZE_OPTION true 'ALL' 'DEFAULT: ALL-DEFAULT | YES: ALL-YES-SHORT & ALL-YES-LONG' "$@"
	#shellcheck disable=SC2034
	case "$ALL" in
		ALL-DEFAULT) ALL_FLAGS='' ;;
		ALL-YES-SHORT) ALL_FLAGS='-a' ;;
		ALL-YES-LONG) ALL_FLAGS='--all' ;;
	esac
}
IS_ALL_ON() {
	printf '%s' "$ALL" | grep -Eq '^ALL-YES-'
}

#shellcheck disable=SC2120
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
	#shellcheck disable=SC2154
	if [ "$meticulousness" -le 3 ]
	then
		PARAMETRIZE_COND "$1" 'END_OPTIONS_INDICATOR' 'EOI-NO'
	else
		PARAMETRIZE_COND "$1" 'END_OPTIONS_INDICATOR' 'EOI-NO' 'EOI-YES'
	fi
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

PARAMETRIZE_PATHSPEC_STYLE() { # keys
	#shellcheck disable=SC2154
	if [ "$meticulousness" -le 2 ]
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
	fi
	PARAMETRIZE_OPTION true 'PATHSPEC' 'ARGS: PS-ARGS | STDIN: PS-STDIN | NULL-STDIN: PS-NULL-STDIN | FILE: PS-FILE | NULL-FILE: PS-NULL-FILE' "$@"
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
PREPARE_PATHSPEC_FILE() {
	if IS_PATHSPEC_NULL_SEP
	then
		tr ' ' '\0'
	else
		tr ' ' '\n'
	fi >"$(git rev-parse --git-dir)/pathspec_for_test"
}

PARAMETRIZE_EXCLUDE() {
	PARAMETRIZE_OPTION true 'EXCLUDE_STYLE' 'EXCLUDE: LONG && EXCL & EXCL_COLON & CARET & CARET_COLON'
	#shellcheck disable=SC2034
	case "$EXCLUDE_STYLE" in
		LONG) EXCLUDE_PATTERN='(exclude)' ;;
		EXCL) EXCLUDE_PATTERN='!' ;;
		EXCL_COLON) EXCLUDE_PATTERN='!:' ;;
		CARET) EXCLUDE_PATTERN='^' ;;
		CARET_COLON) EXCLUDE_PATTERN='^:' ;;
	esac
}

store_stash_CO() { # new_stash_hash
	if CO_STORES_STASH
	then
		test -z "$1" ||
			fail 'The operation "%s" should not print anything to the output!\n' "$CREATE_OPERATION"
	else
		stash_count_before="$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)"
		git stash store "$1" ||
			fail 'Cannot store stash using hash returned by "%s"! ("%s")\n' "$CREATE_OPERATION" "$1"
		stash_count_after="$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)"
		test "$stash_count_after" -gt "$stash_count_before" ||
			fail 'Storing stash produced by "%s" quietly failed! (Possibly a duplicated entry.)\n' "$CREATE_OPERATION"
		unset stash_count_before
		unset stash_count_after
	fi
}
