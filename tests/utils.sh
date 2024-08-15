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
	if [ -n "$1" ]
	then
		sanitize_for_bre "$1"
	else
		printf '%s' '(no branch)'
	fi
}
