#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# "conflicts" are one conflict per line in the format: CONFLICT_TYPE FILE_NAME
assert_outputs__apply__conflict() { # operation conflicts
	# This assertion may be a little frafile because it asserts outputs originated from other Git commands.
	# The goal is not as much to presisely check this output but rather if it is the intended thing in general and whether there is any additional unwanted text.
	assert_outputs "$(
		sanitize_for_ere "$2" \
		| sed -E -e 's/^\t+//' -e 's/^(..) (.*)$/\2 \1/' \
		| sort \
		| sed -E -e 's/^(.*) (..)$/\2 \1/' -e '$!s/.$/&\n\\n/' \
		| sed -E \
			-e 's/^UU (.+)$/Auto-merging \1\\nCONFLICT \\(content\\): Merge conflict in \1/' \
			-e 's/^AA (.+)$/Auto-merging \1\\nCONFLICT \\(add\\\/add\\): Merge conflict in \1/' \
			-e 's/^DU (.+)$/CONFLICT \\(modify\\\/delete\\): \1 deleted in HEAD and modified in [0-9a-fA-F]{7,40} \\(.*\\)\\.  Version [0-9a-zA-Z]{7,40} \\(.*\\) of \1 left in tree\\./' \
			-e 's/^UD (.+)$/CONFLICT \\(modify\\\/delete\\): \1 deleted in [0-9a-fA-F]{7,40} \\(.*\\) and modified in HEAD\\.  Version HEAD of \1 left in tree\\./' \
		| convert_escapes
	)" '
		\n
		hint: Disregard all hints above about using "git rebase"\.\n
		hint: Use "git istash '"$1"' --continue" after fixing conflicts\.\n
		hint: To abort and get back to the state before "git istash '"$1"'", run "git istash '"$1"' --abort"\.
	'
}
assert_outputs__apply__conflict_HT() { # operation normal_conflicts orphan_conflicts
	if ! IS_HEAD_ORPHAN
	then
		assert_outputs__apply__conflict "$1" "$2"
	else
		assert_outputs__apply__conflict "$1" "$3"
	fi
}

assert_outputs__apply__failed_resolution() { # operation unresolved_files
	assert_outputs '
		'"$(sanitize_for_sed "$2")"': needs merge\nYou must edit all merge conflicts and then\nmark them as resolved using git add
	' '
		\n
		hint: Disregard all hints above about using "git rebase"\.\n
		hint: Use "git istash '"$1"' --continue" after fixing conflicts\.\n
		hint: To abort and get back to the state before "git istash '"$1"'", run "git istash '"$1"' --abort"\.
	'
}

# "apply" needs only 1 argument, while "pop" requires all 3.
assert_outputs__apply__success() { # operation [stash_id stash_sha]
	assert_outputs "
		\n
		Successfully applied the stash\n
		Stash of the old working dir: [0-9a-fA-F]{40}
		$(if [ "$1" = 'pop' ] ; then printf '%s' '\n
		Dropped refs\/stash@\{'"$2"'\} \('"$3"'\)\n
		\n
		Successfully popped the stash
		' ; fi)
	" ''
}

assert_outputs__apply__abort() { # operation
	assert_outputs '
	' '
		Aborted "git istash '"$(sanitize_for_sed "$1")"'"
	'
}

assert_outputs__apply__non_stash_on_pop() {
	assert_outputs '
	' '
		error: Only stash entries can be popped\.
	'
}

assert_outputs__apply__no_such_commit() { # commit
	assert_outputs '
	' '
		fatal: There is no commit "'"$(sanitize_for_sed "$1")"'"\.
	'
}

assert_outputs__apply__operation_in_progress() { # operation
	assert_outputs '
	' '
		fatal: "git '"$(sanitize_for_sed "$1")"'" is already in progress\?\n
		hint: Use "git '"$(sanitize_for_sed "$1")"' --continue" or "git '"$(sanitize_for_sed "$1")"' --abort"\.
	'
}

assert_outputs__apply__other_operation_in_progress() { # operation
	assert_outputs '
	' '
		error: There is currently a '"$(sanitize_for_sed "$1")"' in progress\.
	'
}

assert_outputs__apply__no_operation_in_progress() { # operation
	assert_outputs '
	' '
		fatal: No '"$(sanitize_for_sed "$1")"' in progress\?
	'
}

# "existing_files" should be in the format "file0 and file1 is".
# "missing_files" should be in format "files file0 and file1".
assert_outputs__apply__broken_operation_in_progress() { # current_op broken_op existing_files missing_files
	assert_outputs '
	' '
		fatal: "git istash '"$2"'" seems to be in progress but '"$(sanitize_for_sed "$4")"' missing!\n
		hint: Fix the problem and finish that operation before starting '"$(if [ "$1" = "$2" ] ; then printf 'a new one' ; else printf '%s' '"git istash '"$1"'"' ; fi)"'\n
		hint: or remove the '"$(sanitize_for_sed "$3")"' to manually cancel it\.
	'
}

assert_outputs__apply__wrong_head_position_after_rebase() {
	assert_outputs '
	' '
		fatal: HEAD is not in the correct position after rebasing\.
	'
}

assert_outputs__apply__no_rebase_in_progress() {
	assert_outputs '
	' '
		fatal: [Nn]o rebase in progress\??
	'
}

assert_outputs__apply__no_rebase_in_progress_on_abort() { # operation
	assert_outputs '
	' '
		fatal: [Nn]o rebase in progress\??\n
		Aborted "git istash '"$(sanitize_for_sed "$1")"'"
	'
}
