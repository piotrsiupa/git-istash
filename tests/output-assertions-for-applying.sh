#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


create_continue_or_abort_hint_regex() { # operation
	printf '%s' '
		hint: use '\''git istash --continue'\'' after fixing the conflicts\n
		hint: or, to undo everything '\''git istash '"$1"\'' did, run '\''git istash --abort'\''
	'
}

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
	)" "
		$(create_continue_or_abort_hint_regex "$1")
	"
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
	' "
		$(create_continue_or_abort_hint_regex "$1")
	"
}

# "apply" needs only 1 argument, while "pop" requires all 3.
assert_outputs__apply__success() { # operation [stash_id stash_sha]
	assert_outputs '
		Stash of the old working dir: [0-9a-fA-F]{40}\n
		'"$(if [ "$1" = 'pop' ] ; then printf '%s' 'Dropped refs\/stash@\{'"$2"'\} \('"$3"'\)\n' ; fi)"'
		\n
		Successfully '"$(if [ "$1" = 'pop' ] ; then printf 'popped' ; else printf 'applied' ; fi)"' the stash
	' ''
}

assert_outputs__apply__abort() { # operation
	assert_outputs '
	' '
		Successfully aborted '\''git istash '"$(sanitize_for_sed "$1")"\''
	'
}

assert_outputs__apply__quit() { # operation
	assert_outputs '
	' '
		Successfully quit '\''git istash '"$(sanitize_for_sed "$1")"\''
	'
}

assert_outputs__apply__non_stash_on_pop() {
	assert_outputs '
	' '
		error: can only pop '\''refs\/stash'\'' or entries of its reflog
	'
}

assert_outputs__apply__no_such_commit() { # commit
	assert_outputs '
	' '
		error: no commit '\'"$(sanitize_for_sed "$1")"\''
	'
}

assert_outputs__apply__no_operation_in_progress() { # operation
	assert_outputs '
	' '
		error: no '"$(sanitize_for_sed "$1")"' in progress
	'
}

assert_outputs__apply__data_file_not_1_line() { # broken_op data_file
	assert_outputs '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		fatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' doesn'\''t have exactly 1 line\n
		'"$(create_broken_operation_hint_regex)"'
	'
}

assert_outputs__apply__data_file_invalid_commit() { # broken_op data_file
	assert_outputs '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		fatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' contains an invalid commit hash\n
		'"$(create_broken_operation_hint_regex)"'
	'
}

assert_outputs__apply__data_file_invalid_integer() { # broken_op data_file
	assert_outputs '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		fatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' doesn'\''t contain a positive integer\n
		'"$(create_broken_operation_hint_regex)"'
	'
}

assert_outputs__apply__data_file_invalid_stash_number() { # broken_op data_file stash_number
	assert_outputs '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		fatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' contains an invalid stash number\n
		'"$(create_broken_operation_hint_regex)"'
	'
}

assert_outputs__apply__branch_already_used() { # current_op branch
	assert_outputs '
	' '
		fatal: failed to restore HEAD to initial position\n
		fatal: '\'"$(sanitize_for_sed "$2")"\'' is already used by worktree at '\''.*'\''\n
		hint: fix the problems and rerun '\''git istash --abort'\''\n
		hint: or run '\''git istash --quit'\'' to forcefully cancel it
	'
}

assert_outputs__apply__wrong_head_position_after_rebase() {
	assert_outputs '
	' '
		fatal: HEAD is not in the correct position after rebasing
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
		Successfully aborted '\''git istash '"$(sanitize_for_sed "$1")"\''
	'
}

assert_outputs__apply__continue_abort() {
	assert_outputs '
	' '
		error: unclear whether to continue aborting or to abort continuing
	'
}

assert_outputs__apply__continue_quit() {
	assert_outputs '
	' '
		error: unclear whether to continue quitting or to quit continuing
	'
}

assert_outputs__apply__abort_quit() {
	assert_outputs '
	' '
		error: either abort or quit\; there is no middle road
	'
}

assert_outputs__apply__continue_abort_quit() {
	assert_outputs '
	' '
		error: you can choose continue, abort or quit at your discretion but the rule is that you can only have one
	'
}

assert_outputs__apply__wrong_number_of_stash_parents() { # stash_name
	assert_outputs '
	' '
		fatal: '\'"$(sanitize_for_sed "$1")"\'' doesn'\''t have 2 or 3 parents required to be a stash
	'
}

assert_outputs__apply__wrong_number_of_untracked_stash_parents() { # stash_name
	assert_outputs '
	' '
		fatal: '\'"$(sanitize_for_sed "$1")"'\^3'\'' have parents unlike in a stash
	'
}

assert_outputs__apply__wrong_number_of_staged_stash_parents() { # stash_name
	assert_outputs '
	' '
		fatal: '\'"$(sanitize_for_sed "$1")"'\^2'\'' doesn'\''t have one parent like in a stash
	'
}

assert_outputs__apply__wrong_staged_stash_parent() { # stash_name
	assert_outputs '
	' '
		fatal: '\'"$(sanitize_for_sed "$1")"'\^1'\'' isn'\''t the parent of '\'"$(sanitize_for_sed "$1")"'\^2'\'' like in a stash
	'
}

assert_outputs__apply__wrong_stash_commit_messages() { # stash_name
	assert_outputs '
	' '
		fatal: some of '\'"$(sanitize_for_sed "$1")"\'' commits don'\''t have correct messages for a stash\n
		fatal: it may not be a stash entry or it may be damaged
	'
}
