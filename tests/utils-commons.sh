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

__end_of_initialization__() {
	_DEDUPLICATE_PAREMETRIZATION
}

is_facet_active() { # facet_regex
	#shellcheck disable=SC2154
	printf 'always\n%s' "$meticulousness" | grep -E -x -q "$1"
}

non_essential_test() {
	if ! is_facet_active 'non-essential'
	then
		skip_silently
	fi
}

# Captures stdout, stderr and also saves the command
capture_outputs() { # command [arguments...]
	stdout_file="$(mktemp)"
	stderr_file="$(mktemp)"
	exec 7>&1
	error_code="$(
		{
			{
				{
					set +e
					(set -e ; "$@") 8>&2 2>&1 1>&8 8>&-
					printf '%i\n' $? 1>&7
					set -e
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
	#shellcheck disable=SC2034
	last_command="$*"
	return "$error_code"
}

dedent_regex() ( # text
	printf '%s' "$1" | sed -E -e 's/^\t+//' -e 's/^\\\\\t/\t/' | tr -d '\n'
)

match_multiline_regex() { # text regex
	test 'success' = "$(
		if [ ${#2} -le 10000 ]
		then
			#shellcheck disable=SC2016
			printf '%s\n' "$1" \
			| sed -n -E \
				-e '1h' -e '1!H' -e '$g' \
				-e '${s/^'"$2"'$//;ts;bf;}' \
				-e 'd' -e ':s;isuccess' -e 'q' -e ':f;ifailure'
		else
			heredoc="$(mktemp)"
			{
				#shellcheck disable=SC2016
				printf '1h\n1!H\n$g\n'
				#shellcheck disable=SC2016
				printf '${s/^%s$//;ts;bf;}\n' "$2"
				printf 'd\n:s;isuccess\nq\n:f;ifailure\n'
			} >"$heredoc"
			printf '%s\n' "$1" \
			| sed -n -E -f "$heredoc"
			rm "$heredoc" >/dev/null
		fi
	)"
}

sanitize_for_ere() { # [string]
	if [ $# -eq 0 ]
	then
		cat
	else
		printf '%s' "$1"
	fi \
	| sed -E 's/[.[\()*+?{|^$\/]/\\&/g'
}

# Interpret certain escape sequences using "printf". (octal encoded characters, "\t" and "\\")
# The stream must be already sanitized for ERE.
convert_escapes() {
	#shellcheck disable=SC2016
	sed -E -e 's/\\/\\\\/g' -e 's/\\\\\\\\([0-9t])/\\\1/g' -e 's/\\\\\\\\\\\\\\\\/\\\\\\\\/g' \
	| tr '\n' '\0' \
	| xargs -0 -n1 -- sh -c 'printf -- "$1\n"' --
}

sanitize_for_sed() { # string
	sanitize_for_ere "$1" | convert_escapes
}

make_stash_name_regex() { # stash_name
	case "$1" in
	HEAD)	printf '\(no branch\)' ;;
	~*)	sanitize_for_ere "${1#?}" ;;
	*)	sanitize_for_ere "$1" ;;
	esac
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
	while [ "${current_dir%%/*}" = "${istash_abs_path%%/*}" ]
	do
		current_dir="${current_dir#*/}"
		istash_abs_path="${istash_abs_path#*/}"
	done
	printf '%s' "$current_dir" | sed -E 's;[^/]+;..;g'
	printf '/%s\n' "$istash_abs_path"
}

get_relative_istash_path() { # absolute_path
	get_relative_path "$(command -v git-istash)"
}
