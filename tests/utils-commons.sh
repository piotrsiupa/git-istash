#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# This serves both as a pseudo-comment in test code to make it easier to understand and as a way to more easily find where a test failed.
# These names are not displayed during a normal run of a test but the name of the current section is included in the failure message.
# (Multi-line names are not allowed.)
__test_section__() { # section_name
	printf -- '-%s\n' "$1" 1>&4
}

fail() { # printf_arguments...
	#shellcheck disable=SC2059
	printf "$@" 1>&3
	exit 1
}

# Tests with known failures fail when they succeed and succeed when they fail.
known_failure() { # reason
	printf '%s\n' "$1" | sed -E 's/^/+/' 1>&4
}

skip_silently() {
	printf '?' 1>&4
	exit 1
}

non_essential_test() {
	#shellcheck disable=SC2154
	if [ "$meticulousness" -le 0 ]
	then
		skip_silently
	fi
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
	last_command=''
	while [ $# -ne 0 ]
	do
		last_command="$last_command '$(printf '%s' "$1" | sed "s/'/'\\\\''/g")'"
		shift
	done
	last_command="$(printf '%s' "$last_command" | tail -c+2)"
	return "$error_code"
}

command_to_string() { # command [arguments...]
	if [ "$1" = 'capture_outputs' ]
	then
		shift
	fi
	printf '"%s"' "$*"
}

sanitize_for_ere() { # string
	printf '%s' "$1" | sed -E 's/[.[\()*+?{|^$]/\\&/g'
}

make_stash_name_regex() { # stash_name
	if [ "$(printf '%s' "$1" | cut -c1)" = '~' ]
	then
		sanitize_for_ere "$(printf '%s' "$1" | cut -c2-)"
	elif [ "$1" != 'HEAD' ]
	then
		sanitize_for_ere "$1"
	else
		printf '\(no branch\)'
	fi
}

get_head_sha() {
	git rev-parse 'HEAD'
}

get_stash_sha() { # stash_num
	if [ $# -eq 0 ]
	then
		set -- 0
	fi
	git rev-parse "stash@{$1}"
}

remove_all_changes() {
	git reset --hard
	git clean -dfx
}

get_relative_path() { # absolute_path
	current_dir="$(pwd)"
	istash_abs_path="$1"
	while [ "$(printf '%s' "$current_dir" | sed -E 's;^([^/]*/).*$;\1;')" = "$(printf '%s' "$istash_abs_path" | sed -E 's;^([^/]*/).*$;\1;')" ]
	do
		current_dir="$(printf '%s' "$current_dir" | sed -E 's;^[^/]*/(.*)$;\1;')"
		istash_abs_path="$(printf '%s' "$istash_abs_path" | sed -E 's;^[^/]*/(.*)$;\1;')"
	done
	printf '%s' "$current_dir" | sed -E 's;[^/]+;..;g'
	printf '/%s\n' "$istash_abs_path"
}

get_relative_istash_path() { # absolute_path
	get_relative_path "$(command -v git-istash)"
}
