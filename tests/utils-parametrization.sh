#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# This makes the test be called multiple times with the variable from the 1st argument having each of the values from the remaining arguments if the specified facet is active.
# If the facet is not active, the variable is just set to the first value.
# (Reading this code is not sufficient for understanding the function's inner working because it requires cooperation of the script `run.sh` but you don't need that; you just need to know how to use it.)
# The name must be a valid variable name and the values must not contain whitespaces and must not be empty. If it begins with "_", it won't be displayed.
PARAMETRIZE() { # name facet values...
	if ! is_facet_active "$2"
	then
		eval "$1='$3'"
		return 0
	fi
	PARAM_NAME="$1"
	shift 2
	CUR_VAL="$(awk -v key="$PARAM_NAME" '$1 == key { print $2 }' "$PARAMETERS_FILE")"
	LAST_VAL="$(awk -v key="$PARAM_NAME" '$1 == key { print $3 }' "$PARAMETERS_FILE")"
	sed -iE "/^$PARAM_NAME\\>/ d" "$PARAMETERS_FILE"
	if [ "$CUR_VAL" = "$LAST_VAL" ]
	then
		if [ -z "$LAST_VAL" ] || [ "$ROTATE_PARAMETER" = y ]
		then
			CUR_VAL="$1"
		fi
		if [ -z "$LAST_VAL" ]
		then
			ROTATE_PARAMETER=n
		fi
	else
		if [ "$ROTATE_PARAMETER" = y ]
		then
			while [ "$CUR_VAL" != "$1" ] && [ $# -ne 0 ]
			do
				shift
				continue
			done
			shift
			CUR_VAL="$1"
			ROTATE_PARAMETER=n
		fi
	fi
	shift $(($# - 1))
	LAST_VAL="$1"
	eval "$PARAM_NAME"=\"\$CUR_VAL\"
	printf '%s\t%s\t%s\n' "$PARAM_NAME" "$CUR_VAL" "$LAST_VAL" >>"$PARAMETERS_FILE"
	unset PARAM_NAME
	unset CUR_VAL
	unset LAST_VAL
}
_SKIP_PARAMETER() { # name first_value
	CUR_VAL="$(awk -v key="$1" '$1 == key { print $2 }' "$PARAMETERS_FILE")"
	if [ "$CUR_VAL" = "$2" ]
	then
		TMP_FILE="$(mktemp)"
		{
			sed -En '/^'"$1"'/ p' "$PARAMETERS_FILE"
			sed -E '/^'"$1"'/ d' "$PARAMETERS_FILE"
		} >"$TMP_FILE"
		mv "$TMP_FILE" "$PARAMETERS_FILE"
		unset TMP_FILE
	else
		skip_silently
	fi
	unset CUR_VAL
}
# The condition is "eval"ed.
# If it's true, the function behaves like "PARAMETRIZE".
# If it's false, it's like there were never a parameter here.
PARAMETRIZE_COND() { # condition name facet values...
	CONDITION="$1"
	shift
	PARAMETRIZE "$@"
	if is_facet_active "$2" && eval ! "$CONDITION"
	then
		_SKIP_PARAMETER "$1" "$3"
	fi
	unset CONDITION
}
# This is a helper function to make other parameter-related functions.
# It sets the variable to 1 on the first call each run and to 0 otherwise.
# The name must be a valid variable name and the values must not contain whitespaces and must not be empty. If it begins with "_", it won't be displayed.
IS_FIRST_PARAMETRIZE_CALL() { # name
	CUR_VAL="$(awk -v key="$1" '$1 == key { print $2 }' "$PARAMETERS_FILE")"
	eval "$1"=0
	if [ -z "$CUR_VAL" ] || [ -z "$(sed -En '/^--------$/,$ p' "$PARAMETERS_FILE" | awk -v key="$1" '$1 == key { print $2 }')" ]
	then
		eval "$1"=1
	fi
	sed -iE "/^$1\\>/ d" "$PARAMETERS_FILE"
	printf '%s\t%i\t%i\n' "$1" 1 1 >>"$PARAMETERS_FILE"
	unset CUR_VAL
}
# This is a helper function to make other parameter-related functions.
# For the first run it counts how many times it is called and sets the variable to 0 every call.
# For all the subsequent runs it set the variable to 1 on the last call only.
# The name must be a valid variable name and the values must not contain whitespaces and must not be empty. If it begins with "_", it won't be displayed.
IS_LAST_PARAMETRIZE_CALL() { # name
	CUR_VAL="$(awk -v key="$1" '$1 == key { print $2 }' "$PARAMETERS_FILE")"
	LAST_VAL="$(awk -v key="$1" '$1 == key { print $3 }' "$PARAMETERS_FILE")"
	if [ -z "$CUR_VAL" ] || [ -z "$(sed -En '/^--------$/,$ p' "$PARAMETERS_FILE" | awk -v key="$1" '$1 == key { print $2 }')" ]
	then
		CUR_VAL=1
	else
		CUR_VAL=$((CUR_VAL + 1))
	fi
	eval "$1"=0
	if [ -z "$LAST_VAL" ] || [ "$LAST_VAL" -lt "$CUR_VAL" ]
	then
		LAST_VAL="$CUR_VAL"
	elif [ "$LAST_VAL" -eq "$CUR_VAL" ]
	then
		eval "$1"=1
	fi
	sed -iE "/^$1\\>/ d" "$PARAMETERS_FILE"
	printf '%s\t%i\t%i\n' "$1" "$CUR_VAL" "$LAST_VAL" >>"$PARAMETERS_FILE"
	unset CUR_VAL
	unset LAST_VAL
}
# Before the values are passed to "PARAMETRIZE_COND", they are expanded using the map.
# This is good to create wrapper funcitons to e.g. cover both spellings of option "-k" and "--keep-index" and have to specify only one parameter in the function call.
# (If no key is passed, all values are used.)
# Level of meticulousness affects which variants are used or skipped.
PARAMETRIZE_OPTION() { # condition name override_facet map values...
	CONDITION="$1"
	NAME="$2"
	FACET="${3:-options}"
	#shellcheck disable=SC2020
	MAP="$(printf '%s' "$4" | sed -E 's/\s+//g' | tr '|' '\n' | sed -E 's/^(.+:)(.*&&)(.*&&)(.*)$/\1\3\2\4/')"
	shift 4
	if ! is_facet_active 'short-options'
	then
		MAP="$(printf '%s\n' "$MAP" | sed -E 's/^(.+:)(.*&&).*&&(.*)$/\1\2\3/')"
	fi
	if ! is_facet_active 'partial-options'
	then
		MAP="$(printf '%s\n' "$MAP" | sed -E 's/^(.+:)(.*)&&(&?[^&])*$/\1\2/')"
	fi
	if [ $# -eq 0 ]
	then
		VALUES="$(printf '%s\n' "$MAP" | cut -d: -f2-)"
	else
		VALUES=''
		while [ $# -ne 0 ]
		do
			printf '%s\n' "$MAP" | grep -qE "^$1:" ||
				fail 'Key "%s" cannot be found by "PARAMETRIZE_OPTION"!\n' "$1"
			VALUES="$VALUES$(printf '\n' ; printf '%s\n' "$MAP" | grep -E "^$1:" | cut -d: -f2-)"
			shift
		done
	fi
	if ! is_facet_active "$FACET"
	then
		VALUES="$(printf '%s\n' "$VALUES" | grep -v '^$' | head -n1)"
	fi
	VALUES="$(printf '%s\n' "$VALUES" | tr '&' '\n' | sed -E -e '/^\s*$/ d' -e "s/'/'\\\\''/g" -e "s/^/'/" -e "s/$/'/" | tr '\n' ' ')"
	eval set -- "$VALUES"
	PARAMETRIZE_COND "$CONDITION" "$NAME" 'always' "$@"
	unset CONDITION
	unset NAME
	unset FACET
	unset MAP
	unset VALUES
}

# It calls "PARAMETRIZE" with the name "HEAD_TYPE", the facet "head-type" and possible values "BRANCH", "DETACH" and "ORPHAN".
# There is a bunch of functions in this and other files that use the variable "HEAD_TYPE". (They always have suffix "_HT".)
# (See also the function below this one.)
PARAMETRIZE_HEAD_TYPE() { # values...
	! printf '%s\n' "$@" | grep -vxqE "BRANCH|DETACH|ORPHAN" ||
		fail '"HEAD_TYPE" can be only "BRANCH", "DETACH" or "ORPHAN"!\n'
	PARAMETRIZE 'HEAD_TYPE' 'head-type' "$@"
}
IS_HEAD_BRANCH() {
	test "$HEAD_TYPE" = 'BRANCH'
}
IS_HEAD_DETACHED() {
	test "$HEAD_TYPE" = 'DETACH'
}
IS_HEAD_ORPHAN() {
	test "$HEAD_TYPE" = 'ORPHAN'
}
SWITCH_HEAD_TYPE() {
	case "$HEAD_TYPE" in
		'BRANCH') ;;
		'DETACH') git switch --detach 'HEAD' ;;
		'ORPHAN') git switch --orphan 'ooo' ;;
	esac
}
RESTORE_HEAD_TYPE() {
	git switch 'master'
}
get_head_sha_HT() {
	if ! IS_HEAD_ORPHAN
	then
		get_head_sha
	fi
}

#shellcheck disable=SC2120
PARAMETRIZE_COLOR() { # keys
	# "auto" is not tested here, because it's not really viable to capture program output while doing that.
	PARAMETRIZE_OPTION true 'COLOR' 'color' 'YES: COLOR-LONG && COLOR-YES-LONG && COLOR-YES-LONGISH0 & COLOR-YES-LONGISH1 | NO: COLOR-NO-LONG & NO-COLOR-LONG && COLOR-DEFAULT && COLOR-NO-LONGISH0 & COLOR-NO-LONGISH1 & NO-COLOR-LONGISH0 & NO-COLOR-LONGISH1' "$@"
	#shellcheck disable=SC2034
	case "$COLOR" in
		COLOR-LONG) COLOR_FLAGS='--color' ;;
		COLOR-YES-LONG) COLOR_FLAGS='--color=always' ;;
		COLOR-YES-LONGISH0) COLOR_FLAGS='--colo=YES' ;;
		COLOR-YES-LONGISH1) COLOR_FLAGS='--col=t' ;;
		COLOR-DEFAULT) COLOR_FLAGS='' ;;
		COLOR-NO-LONG) COLOR_FLAGS='--color=never' ;;
		NO-COLOR-LONG) COLOR_FLAGS='--no-color' ;;
		COLOR-NO-LONGISH0) COLOR_FLAGS='--colo=NO' ;;
		COLOR-NO-LONGISH1) COLOR_FLAGS='--col=0' ;;
		NO-COLOR-LONGISH0) COLOR_FLAGS='--no-col' ;;
		NO-COLOR-LONGISH1) COLOR_FLAGS='--no-c' ;;
	esac
}
IS_COLOR_ON() {
	printf '%s' "$COLOR" | grep -Eq '^COLOR-YES-|^COLOR-LONG$'
}
