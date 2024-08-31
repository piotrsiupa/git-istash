#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


fail() { # printf_arguments...
	#shellcheck disable=SC2059
	printf "$@" 1>&3
	return 1
}

capture_outputs() { # command [arguments...]
	stdout_file="$(mktemp)"
	stderr_file="$(mktemp)"
	exec 7>&1
	error_code="$(
		set +e
		{
			{
				{
					"$@" 8>&2 2>&1 1>&8 8>&-
					printf '%i\n' $? 1>&7
				} | tee "$stderr_file"
			} 8>&2 2>&1 1>&8 8>&- | tee "$stdout_file"
		} 8>&7 7>&1 1>&8 8>&-
	)"
	exec 7>&-
	#shellcheck disable=SC2034
	stdout="$(cat "$stdout_file")"
	rm "$stdout_file"
	unset stdout_file
	#shellcheck disable=SC2034
	stderr="$(cat "$stderr_file")"
	rm "$stderr_file"
	unset stderr_file
	return "$error_code"
}

command_to_string() { # command [arguments...]
	if [ "$1" = 'capture_outputs' ]
	then
		shift
	fi
	printf '"%s"' "$*"
}

sanitize_for_bre() { # string
	printf '%s' "$1" | sed 's/[.*[\^$]/\\&/g'
}

make_stash_name_regex() { # stash_name
	if [ "$(printf '%s' "$1" | cut -c1)" = '~' ]
	then
		sanitize_for_bre "$(printf '%s' "$1" | cut -c2-)"
	elif [ "$1" != 'HEAD' ]
	then
		sanitize_for_bre "$1"
	else
		printf '(no branch)'
	fi
}

get_head_hash() {
	git rev-parse 'HEAD'
}

get_stash_hash() { # stash_num
	if [ $# -eq 0 ]
	then
		set -- 0
	fi
	git rev-parse "stash@{$1}"
}

# This makes the test be called multiple times with the variable from the 1st argument having each of the values from the remaining arguments.
# (Reading this code is not sufficient for understanding the function's inner working because it requires cooperation of the script `run.sh` but you don't need that; you just need to know how to use it.)
# The name must be a valid variable name and the values must not contain whitespaces and must not be empty.
PARAMETRIZE() { # name values...
	PARAM_NAME="$1"
	shift
	CUR_VAL="$(awk '$1 == "'"$PARAM_NAME"'" { print $2 }' "$PARAMETERS_FILE")"
	LAST_VAL="$(awk '$1 == "'"$PARAM_NAME"'" { print $3 }' "$PARAMETERS_FILE")"
	sed -i "/^$PARAM_NAME\\>/ d" "$PARAMETERS_FILE"
	if [ "$CUR_VAL" = "$LAST_VAL" ]
	then
		if [ -z "$LAST_VAL" ] || [ "$ROTATE_PARAMETER" = y ]
		then
			CUR_VAL="$1"
		fi
		if [ -z "$LAST_VAL" ]
		then
			ROTATE_PARAMETER=n
		else
			ROTATE_PARAMETER=y
		fi
	else
		while [ "$CUR_VAL" != "$1" ] && [ $# -ne 0 ]
		do
			shift
			continue
		done
		if [ "$ROTATE_PARAMETER" = y ]
		then
			shift
			CUR_VAL="$1"
		fi
		ROTATE_PARAMETER=n
	fi
	shift $(($# - 1))
	LAST_VAL="$1"
	eval "$PARAM_NAME"=\"\$CUR_VAL\"
	printf '%s\t%s\t%s\n' "$PARAM_NAME" "$CUR_VAL" "$LAST_VAL" >>"$PARAMETERS_FILE"
	unset PARAM_NAME
	unset CUR_VAL
	unset LAST_VAL
}

# It calls "PARAMETRIZE" with the name "HEAD_TYPE" and possible values "BRANCH", "DETACH" and "ORPHAN".
# There is a bunch of functions in this and other files that use the variable "HEAD_TYPE". (They always have suffix "_H".)
# (See also the function below this one.)
PARAMETRIZE_HEAD_TYPE() { # values...
	! printf '%s\n' "$@" | grep -vxq "BRANCH\|DETACH\|ORPHAN" ||
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
