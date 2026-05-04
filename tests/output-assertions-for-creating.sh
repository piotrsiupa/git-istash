#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# This is kinda testing the output of vanilla git command but without this part I would have trouble assessing if output of istash itself is correct.
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

create_patch_output_regex_for_single_call() { # (t|u) [nr_of_questions...]
	printf '### Using the interactive patch for %s files\\.\\.\\.' "$(if [ "$1" = u ] ; then printf 'untracked' ; else printf 'tracked' ; fi)"
	shift
	printf '%s' '\n\n'
	if [ $# -ne 0 ]
	then
		while [ $# -ne 0 ]
		do
			create_patch_output_regex_for_single_file "$1"
			shift
			if [ $# -ne 0 ]
			then
				printf '%s' '\n'
			fi
		done
	else
		printf '%s' 'No changes\.'
	fi
}

# "call_description" is a number of questions in every file, separated by ",".
# E.g. "2,3" means that the first file in a call has 2 questions and the second one has 3.
# Empty string means no files.
create_patch_output_regex() { # [call_description...]
	while [ $# -ne 0 ]
	do
		#shellcheck disable=SC2046
		create_patch_output_regex_for_single_call $(printf '%s' "$1" | tr ',' ' ')
		shift
		if [ $# -ne 0 ]
		then
			printf '%s' '\n\n\n'
		fi
	done
}

# See "assert_outputs__create__success" for info on the summary code.
create_success_message_regex() { # summary_code branch_name base_commit message
	if IS_QUIET
	then
		return
	fi
	printf 'Saved '
	printf '%s' "$1" \
	| sed -E -e 's/^[^-]+-//' -e 's/./&\n/g' | tr 'WSUI' '1-4' | tr -d -c '1-4\n' | sort | tr '1-4' 'WSUI' | tr -d '\n' \
	| sed -E -e 's/./&,/g' -e 's/,$//' -e 's/U,I/UI/' -e 's/,/, /g' -e 's/,([^,]+)$/ \&\1/' \
	| sed -E -e 's/W/working directory/' -e 's/S/index state/' -e 's/UI/untracked files \\(including ignored\\)/' -e 's/U/untracked files/' -e 's/I/ignored files/' -e 's/\&/and/' | grep '.' || printf 'nothing'
	if [ -n "$4" ]
	then
		printf ' On %s: %s' "$(sanitize_for_sed "$2")" "$(sanitize_for_sed "$4")"
	else
		printf ' WIP on %s: %s' "$(sanitize_for_sed "$2")" "$(sanitize_for_ere "$(git rev-list --no-commit-header --format='%h %s' --max-count=1 "$3")")"
	fi
	case "$1" in
		create-*)	;;
		save-*)		printf '\\n\nStored the stash in the stash ref' ;;
		snatch-*)	printf '\\n\nReverted the saved changes' ;;
		push-*)		printf '\\n\nReverted the saved changes and stored the stash in the stash ref' ;;
	esac
}

make_summary_code() {
	if IS_STAGED_ON
	then
		printf 'S'
	fi
	if IS_UNSTAGED_ON
	then
		printf 'W'
	fi
	if IS_ALL_ON
	then
		printf 'I'
		if ! IS_UNTRACKED_OFF
		then
			printf 'U'
		fi
	else
		if IS_UNTRACKED_ON
		then
			printf 'U'
		fi
	fi
}

# Use the "*" version for automatic values which is recommended unless it's some weird situation.
# It generates the summary code, takes the current branch name and the "stash@{$stash_num}~" as the base commit.
# summary_code - letters describing which files were stashed (order not important):
#	+ W -> working directory files
#	+ S -> state of the index
#	+ U -> untracked files
#	+ I -> ignored files
# branch_name - the current branch name (empty for detached HEAD)
# base_commit - the commit on which the stash was created
# commit_message - message / name of the stash (empty for no message)
# call_description - see "create_patch_output_regex"
#shellcheck disable=SC2120
assert_outputs__create__success() { # ('*' stash_num message | summary_code branch_name base_commit message) [call_description...]
	if [ "$1" = '*' ]
	then
		stash_number_for_assertion="$2"
		shift 2
		#shellcheck disable=SC2154
		set -- "$(make_summary_code)" \
			"$(if IS_HEAD_DETACHED ; then printf '(no branch)' ; else git branch --show-current ; fi)" \
			"$(if CO_STORES_STASH ; then printf '%s' "stash@{$stash_number_for_assertion}" ; else printf '%s' "$stdout" ; fi)~" \
			"$@"
		unset stash_number_for_assertion
	fi
	
	assert_outputs "$(
		if ! CO_STORES_STASH
		then
			printf '%s' '[0-9a-fA-F]{7,40}'
		fi
	)" '
		'"$(shift 4 ; create_patch_output_regex "$@")"'
		'"$(if [ $# -gt 4 ] && ! IS_QUIET ; then printf '%s' '\n\n\n' ; fi)"'
		'"$(create_success_message_regex "$1" "$2" "$3" "$4")"'
	'
}

#shellcheck disable=SC2120
assert_outputs__create__no_changes_to_stash() { # [call_description...]
	assert_outputs_with_color '
	' '
		'"$(create_patch_output_regex "$@")"'
		'"$(if [ $# -ne 0 ] ; then printf '%s' '\n\n\n' ; fi)"'
		\[<color>31merror: no suitable changes to stash\[<color>0?m
	'
}

assert_outputs__create__unmatching_pathspec() { # pathspec
	assert_outputs_with_color '
	' '
		\[<color>31merror: pathspec '"'$(sanitize_for_sed "$1")'"' did not match any file\(s\)\[<color>0?m
	'
}

assert_outputs__create__pfn_without_pff() {
	assert_outputs_with_color '
	' '
		\[<color>31merror: option '\''--pathspec-file-nul'\'' is not valid without '\''--pathspec-from-file'\''\[<color>0?m
	'
}

assert_outputs__create__patch_with_patchspec() {
	assert_outputs_with_color '
	' '
		\[<color>31merror: stdin cannot be assigned to both '\''--patch'\'' and the pathspec\[<color>0?m
	'
}
