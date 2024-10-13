#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# This makes the test be called multiple times with the variable from the 1st argument having each of the values from the remaining arguments.
# (Reading this code is not sufficient for understanding the function's inner working because it requires cooperation of the script `run.sh` but you don't need that; you just need to know how to use it.)
# The name must be a valid variable name and the values must not contain whitespaces and must not be empty.
PARAMETRIZE() { # name values...
	PARAM_NAME="$1"
	shift
	CUR_VAL="$(awk '$1 == "'"$PARAM_NAME"'" { print $2 }' "$PARAMETERS_FILE")"
	LAST_VAL="$(awk '$1 == "'"$PARAM_NAME"'" { print $3 }' "$PARAMETERS_FILE")"
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
# The condition is "eval"ed.
# If it's true, the function behaves like "PARAMETRIZE".
# If it's false, it's like there were never a parameter here.
PARAMETRIZE_COND() { # condition name values...
	CONDITION="$1"
	shift
	PARAMETRIZE "$@"
	if eval ! "$CONDITION"
	then
		CUR_VAL="$(awk '$1 == "'"$1"'" { print $2 }' "$PARAMETERS_FILE")"
		if [ "$CUR_VAL" = "$2" ]
		then
			TMP_FILE="$(mktemp)"
			{
				sed -En '/^'"$1"'/ p' "$PARAMETERS_FILE"
				sed -E '/^'"$1"'/ d' "$PARAMETERS_FILE"
			} >"$TMP_FILE"
			mv "$TMP_FILE" "$PARAMETERS_FILE"
			unset TMP_FILE
			unset "$1"
		else
			skip_silently
		fi
		unset CUR_VAL
	fi
	unset CONDITION
}
# Before the values are passed to "PARAMETRIZE_COND", they are expanded using the map.
# This is good to create wrapper funcitons to e.g. cover both spellings of option "-k" and "--keep-index" and have to specify only one parameter in the function call.
# (If no key is passed, all values are used.)
# Level of meticulousness affects which variants are used or skipped.
PARAMETRIZE_OPTION() { # condition name map values...
	CONDITION="$1"
	NAME="$2"
	#shellcheck disable=SC2020
	MAP="$(printf '%s' "$3" | sed -E 's/\s+//g' | tr ':&|' '  \n')"
	#shellcheck disable=SC2154
	if [ "$meticulousness" -le 2 ]
	then
		MAP="$(printf '%s' "$MAP" | awk '{print $1,$2}')"
	fi
	shift 3
	if [ $# -eq 0 ]
	then
		VALUES="$(printf '%s\n' "$MAP" | awk '{for (i = 2; i <= NF; i++) {print $i}}')"
	else
		VALUES=''
		while [ $# -ne 0 ]
		do
			printf '%s\n' "$MAP" | grep -qE "^$1\\s" ||
				fail 'Key "%s" cannot be found by "PARAMETRIZE_OPTION"!\n' "$1"
			VALUES="$VALUES$(printf '\n' ; printf '%s\n' "$MAP" | awk -v key="$1" '$1 == key {for (i = 2; i <= NF; i++) {print $i}}')"
			shift
		done
	fi
	VALUES="$(printf '%s\n' "$VALUES" | sed -E -e '/^\s*$/ d' -e "s/'/'\\\\''/g" -e "s/^/'/" -e "s/$/'/" | tr '\n' ' ')"
	eval set -- "$VALUES"
	PARAMETRIZE_COND "$CONDITION" "$NAME" "$@"
	unset CONDITION
	unset NAME
	unset MAP
	unset VALUES
}

# It calls "PARAMETRIZE" with the name "HEAD_TYPE" and possible values "BRANCH", "DETACH" and "ORPHAN".
# There is a bunch of functions in this and other files that use the variable "HEAD_TYPE". (They always have suffix "_H".)
# (See also the function below this one.)
PARAMETRIZE_HEAD_TYPE() { # values...
	! printf '%s\n' "$@" | grep -vxqE "BRANCH|DETACH|ORPHAN" ||
		fail '"HEAD_TYPE" can be only "BRANCH", "DETACH" or "ORPHAN"!\n'
	PARAMETRIZE 'HEAD_TYPE' "$@"
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
get_head_hash_H() {
	if ! IS_HEAD_ORPHAN
	then
		get_head_hash
	fi
}
