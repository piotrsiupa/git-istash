#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


create_patch_output_regex_for_single_file() { # nr_of_questions
	printf '%s' '
		diff .*\n
		(
			index [0-9a-fA-F]{7,40}\.\.[0-9a-fA-F]{7,40} 100644\n
		|
			(new|deleted) file mode 100644\n
			index [0-9a-fA-F]{7,40}\.\.[0-9a-fA-F]{7,40}\n
		)
		--- .*\n
		\+\+\+ .*\n
		(
			@@ .* @@\n
			([-+ ].*\n)+
			\([1-9][0-9]*\/[1-9][0-9]*\) Stage (this hunk|addition|deletion) \[.(,.)*\]\? 
			(Split into [1-9][0-9]* hunks\.\n)?
		){'"$1"'}
	'
}

create_patch_output_regex_for_single_call() { # ends_with_new_line [nr_of_questions...]
	printf '%s' '### .*\.\.\.'
	if [ $# -gt 1 ]
	then
		ends_with_new_line="$1"
		shift
		while [ $# -ne 0 ]
		do
			create_patch_output_regex_for_single_file "$1"
			shift
			if [ $# -ne 0 ] || [ "$ends_with_new_line" = y ]
			then
				printf '%s' '\n'
			fi
		done
		unset ends_with_new_line
	else
		if [ "$1" = y ]
		then
			printf '%s' '(No changes\.\n)?'
		else
			printf '%s' '(No changes\.)?'
		fi
	fi
}

# "call_description" is a number of questions in every file, separated by ",".
# E.g. "2,3" means that the first file in a call has 2 questions and the second one has 3.
# Empty string means no files.
create_patch_output_regex() { # ends_with_new_line [call_description...]
	last_ends_with_new_line="$1"
	shift
	while [ $# -ge 2 ]
	do
		#shellcheck disable=SC2046
		create_patch_output_regex_for_single_call y $(printf '%s' "$1" | tr ',' ' ')
		shift
	done
	if [ $# -eq 1 ]
	then
		#shellcheck disable=SC2046
		create_patch_output_regex_for_single_call "$last_ends_with_new_line" $(printf '%s' "$1" | tr ',' ' ')
	fi
	unset last_ends_with_new_line
}


#shellcheck disable=SC2120
assert_outputs__create__success() { # [call_description...]
	assert_outputs "$(
		if ! CO_STORES_STASH
		then
			printf '%s' '[0-9a-fA-F]{7,40}'
		fi
	)" "$(
		create_patch_output_regex n "$@"
	)"
}

#shellcheck disable=SC2120
assert_outputs__create__no_changes_to_stash() { # [call_description...]
	assert_outputs '
	' "
		$(create_patch_output_regex y "$@")
		fatal: There are no suitable changes to stash\\.
	"
}

assert_outputs__create__unmatching_pathspec() { # pathspec
	assert_outputs '
	' '
		fatal: pathspec '"'$(sanitize_for_sed "$1")'"' did not match any files
	'
}

assert_outputs__create__operation_in_progress() { # operation
	assert_outputs '
	' '
		error: There is currently '"$(sanitize_for_sed "$1")"' in progress.
	'
}

assert_outputs__create__broken_operation_in_progress() { # operation
	assert_outputs '
	' '
		error: There is currently an istash error-'"$(sanitize_for_sed "$1")"' in progress.
	'
}
