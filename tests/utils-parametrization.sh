#!/usr/bin/env sh


# This makes the test be called multiple times with the variable from the 1st argument having each of the values from the remaining arguments.
# (Reading this code is not sufficient for understanding the function's inner working because it requires cooperation of the script `run.sh` but you don't need that; you just need to know how to use it.)
# The name must be a valid variable name and the values must not contain whitespaces and must not be empty. If it begins with "_", it won't be displayed.
PARAMETRIZE() { # name values...
	PARAM_NAME="$1"
	shift
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
		unset "$1"
	else
		skip_silently
	fi
	unset CUR_VAL
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
		_SKIP_PARAMETER "$1" "$2"
	fi
	unset CONDITION
}
# This is kinda similar to `PARAMETRIZE` but not really.
# Instead of list of arguments it takes a range of numbers and iterates over them in order.
# Unlike `PARAMETRIZE`, it can be called multiple times in a single run without side effects. (It will return the same number every time.)
# If it's called multiple times with different upper ends of the range, it will always choose the biggest one. (The lower ends must be the same in every call.)
# The name must be a valid variable name and the values must not contain whitespaces and must not be empty. If it begins with "_", it won't be displayed.
PARAMETRIZE_BIGGEST() { # name first_number last_number
	CUR_VAL="$(awk -v key="$1" '$1 == key { print $2 }' "$PARAMETERS_FILE")"
	LAST_VAL="$(awk -v key="$1" '$1 == key { print $3 }' "$PARAMETERS_FILE")"
	if [ -z "$(sed -En '/^--------$/,$ p' "$PARAMETERS_FILE" | awk -v key="$1" '$1 == key { print $2 }')" ]
	then
		if [ "$CUR_VAL" = "$LAST_VAL" ]
		then
			if [ -z "$LAST_VAL" ] || [ "$ROTATE_PARAMETER" = y ]
			then
				CUR_VAL="$2"
			fi
			if [ -z "$LAST_VAL" ]
			then
				ROTATE_PARAMETER=n
			fi
		else
			if [ "$ROTATE_PARAMETER" = y ]
			then
				CUR_VAL=$((CUR_VAL + 1))
				ROTATE_PARAMETER=n
			fi
		fi
	fi
	eval "$1"=\"\$CUR_VAL\"
	if [ -z "$LAST_VAL" ] || [ "$LAST_VAL" -lt "$3" ]
	then
		LAST_VAL="$3"
	fi
	sed -iE "/^$1\\>/ d" "$PARAMETERS_FILE"
	printf '%s\t%i\t%i\n' "$1" "$CUR_VAL" "$LAST_VAL" >>"$PARAMETERS_FILE"
	unset CUR_VAL
	unset LAST_VAL
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
PARAMETRIZE_OPTION() { # condition name map values...
	CONDITION="$1"
	NAME="$2"
	#shellcheck disable=SC2020
	MAP="$(printf '%s' "$3" | sed -E 's/\s+//g' | tr ':&|' '  \n')"
	shift 3
	#shellcheck disable=SC2154
	if [ "$meticulousness" -le 2 ]
	then
		MAP="$(printf '%s' "$MAP" | awk '{print $1,$2}')"
	elif [ "$meticulousness" -le 4 ]
	then
		MAP="$(printf '%s' "$MAP" | sed -E 's/  .*$//')"
	else
		MAP="$(printf '%s' "$MAP" | sed -E 's/^(\S+ ).*  (.+)$/\1\2/')"
	fi
	if [ $# -eq 0 ]
	then
		VALUES="$(printf '%s\n' "$MAP" | awk '{$1=""} 1')"
	else
		VALUES=''
		while [ $# -ne 0 ]
		do
			printf '%s\n' "$MAP" | grep -qE "^$1\\s" ||
				fail 'Key "%s" cannot be found by "PARAMETRIZE_OPTION"!\n' "$1"
			VALUES="$VALUES$(printf '\n' ; printf '%s\n' "$MAP" | awk -v key="$1" '$1 == key {$1=""; print}')"
			shift
		done
	fi
	if [ "$meticulousness" -ne 3 ]
	then
		VALUES="$(printf '%s\n' "$VALUES" | tr ' ' '\n' | sed -E -e '/^\s*$/ d' -e "s/'/'\\\\''/g" -e "s/^/'/" -e "s/$/'/" | tr '\n' ' ')"
		eval set -- "$VALUES"
		PARAMETRIZE_COND "$CONDITION" "$NAME" "$@"
	else
		VALUES="$(printf '%s\n' "$VALUES" | sed -E '/^\s*$/ d')"
		PARAMETRIZE_BIGGEST '_OPTION_COL' 1 "$(printf '%s' "$VALUES" | awk '{if (NF > x) {x = NF}} END {print x}')"
		PARAMETRIZE_BIGGEST "$NAME" 1 "$(printf '%s\n' "$VALUES" | wc -l)"
		eval ROW=\$"$NAME"
		VALUE="$(printf '%s\n' "$VALUES" | awk -v row="$ROW" -v col="$_OPTION_COL" 'NR == row {if (NF <= col) {print $NF} else {print $col}}')"
		sed -Ei "/^$NAME\\>/ s/\$/ $VALUE/" "$PARAMETERS_FILE"
		eval "$NAME"=\"\$VALUE\"
		if ! eval "$CONDITION"
		then
			_SKIP_PARAMETER "$NAME" 1
		fi
		IS_FIRST_PARAMETRIZE_CALL '_OPTION_FIRST'
		if [ "$_OPTION_FIRST" -eq 1 ]
		then
			_OPTION_MAX_COLS=1
		fi
		MAX_COLS="$(printf '%s\n' "$VALUES" | awk -v row="$ROW" 'NR == row {print NF}')"
		if [ "$MAX_COLS" -gt "$_OPTION_MAX_COLS" ]
		then
			_OPTION_MAX_COLS="$MAX_COLS"
		fi
		IS_LAST_PARAMETRIZE_CALL '_OPTION_LAST'
		if [ "$_OPTION_LAST" -eq 1 ] && [ "$_OPTION_COL" -gt "$_OPTION_MAX_COLS" ]
		then
			skip_silently
		fi
		unset ROW
		unset VALUE
		unset _OPTION_COL
		unset _OPTION_FIRST
		unset _OPTION_LAST
		unset MAX_COLS
	fi
	unset CONDITION
	unset NAME
	unset MAP
	unset VALUES
}

# It calls "PARAMETRIZE" with the name "HEAD_TYPE" and possible values "BRANCH", "DETACH" and "ORPHAN".
# There is a bunch of functions in this and other files that use the variable "HEAD_TYPE". (They always have suffix "_HT".)
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
get_head_hash_HT() {
	if ! IS_HEAD_ORPHAN
	then
		get_head_hash
	fi
}
