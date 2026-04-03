#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


create_continue_or_abort_hint_regex() { # operation
	printf '%s' '
		\[33mhint: use '\''git istash --continue'\'' after fixing the conflicts\[0?m\n
		\[33mhint: or, to undo everything '\''git istash '"$1"\'' did, run '\''git istash --abort'\''\[0?m
	'
}

# "conflicts" are one conflict per line in the format: CONFLICT_TYPE FILE_NAME
assert_outputs__apply__conflict() { # operation conflicts
	# This assertion may be a little frafile because it asserts outputs originated from other Git commands.
	# The goal is not as much to presisely check this output but rather if it is the intended thing in general and whether there is any additional unwanted text.
	assert_outputs_with_color "$(
		sanitize_for_ere "$2" \
		| sed -E -e 's/^\t+//' -e 's/^(..) (.*)$/\2 \1/' \
		| LC_ALL=C sort \
		| sed -E -e 's/^(.*) (..)$/\2 \1/' -e '$!s/.$/&\n\\n/' \
		| sed -E \
			-e 's/^UU (.+)$/<no-strip-color>Auto-merging \1\\nCONFLICT \\(content\\): Merge conflict in \1/' \
			-e 's/^AA (.+)$/<no-strip-color>Auto-merging \1\\nCONFLICT \\(add\\\/add\\): Merge conflict in \1/' \
			-e 's/^DU (.+)$/<no-strip-color>CONFLICT \\(modify\\\/delete\\): \1 deleted in HEAD and modified in [0-9a-fA-F]{7,40} \\(.*\\)\\.  Version [0-9a-zA-Z]{7,40} \\(.*\\) of \1 left in tree\\./' \
			-e 's/^UD (.+)$/<no-strip-color>CONFLICT \\(modify\\\/delete\\): \1 deleted in [0-9a-fA-F]{7,40} \\(.*\\) and modified in HEAD\\.  Version HEAD of \1 left in tree\\./' \
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
	assert_outputs_with_color '
		'"$(sanitize_for_sed "$2")"': needs merge\nYou must edit all merge conflicts and then\nmark them as resolved using git add
	' "
		$(create_continue_or_abort_hint_regex "$1")
	"
}

# "apply" needs only 2 arguments, while "pop" requires all 4.
assert_outputs__apply__success() { # operation changes [stash_id stash_sha]
	assert_outputs_with_color '
		'"$(
			changes="$(
				printf '%s\n' "$2" \
				| sed -E -e 's/^\t+//' -e '/^\s*$/ d' -e 's/^\\\?/?/' -e 's/^(..) (.+)$/\2 \1/' \
				| LC_ALL=C sort \
				| sed -E 's/^(.+) (..)$/\2 \1/'
			)"
			if printf '%s' "$changes" | grep -q '.'
			then
				printf 'Changes made to the working directory:\\n\n'
				if printf '%s' "$changes" | grep -Eq '^[^ ?!]'
				then
					printf '    index:\\n\n'
					printf '%s' "$changes" \
					| grep -E '^[^ ?!]' \
					| sed -E -e 's/^A. (.+)$/\\\\t\[32madded:\\t\\t\1\[0?m\\n/' \
						-e 's/^M. (.+)$/\\\\t\[32mmodified:\\t\1\[0?m\\n/' \
						-e 's/^D. (.+)$/\\\\t\[32mdeleted:\\t\1\[0?m\\n/'
				fi
				if printf '%s' "$changes" | grep -Eq '^[^?!][^ ]'
				then
					printf '    tracked files:\\n\n'
					printf '%s' "$changes" \
					| grep -E '^[^?!][^ ]' \
					| sed -E -e 's/^.A (.+)$/\\\\t\[31madded:\\t\\t\1\[0?m\\n/' \
						-e 's/^.M (.+)$/\\\\t\[31mmodified:\\t\1\[0?m\\n/' \
						-e 's/^.D (.+)$/\\\\t\[31mdeleted:\\t\1\[0?m\\n/'
				fi
				if printf '%s' "$changes" | grep -Eq '^[?!]'
				then
					printf '    untracked files:\\n\n'
					printf '%s' "$changes" \
					| grep -E '^[?!]' \
					| sed -E -e 's/^!! (.+)$/\\\\t\[31mignored:\\t\1\[0?m\\n/' \
						-e 's/^!. (.+)$/\\\\t\[31mtouched:\\t\1\[0?m\\n/' \
						-e 's/^.A (.+)$/\\\\t\[31mcreated:\\t\1\[0?m\\n/' \
						-e 's/^.M (.+)$/\\\\t\[31mmodified:\\t\1\[0?m\\n/' \
						-e 's/^.D (.+)$/\\\\t\[31mdeleted:\\t\1\[0?m\\n/'
				fi
			else
				printf 'No changes were made to the working directory.\\n\n'
			fi \
			| sanitize_for_ere \
			| convert_escapes \
			| sed -E -e 's/\\\\n/\\n/g' \
				-e 's/\\\[0\\\?m/\\[0?m/g'
		)"'
		\n
		Stash of the old working dir: [0-9a-fA-F]{40}\n
		'"$(if [ "$1" = 'pop' ] ; then printf '%s' 'Dropped refs\/stash@\{'"$3"'\} \('"$4"'\)\n' ; fi)"'
		\n
		Successfully '"$(if [ "$1" = 'pop' ] ; then printf 'popped' ; else printf 'applied' ; fi)"' the stash
	' ''
}
# "apply" needs only 3 arguments, while "pop" requires all 5.
assert_outputs__apply__success_HT() { # operation changes_normal changes_orphan [stash_id stash_sha]
	if ! IS_HEAD_ORPHAN
	then
		if [ $# -eq 5 ]
		then
			assert_outputs__apply__success "$1" "$2" "$4" "$5"
		else
			assert_outputs__apply__success "$1" "$2"
		fi
	else
		if [ $# -eq 5 ]
		then
			assert_outputs__apply__success "$1" "$3" "$4" "$5"
		else
			assert_outputs__apply__success "$1" "$3"
		fi
	fi
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
	assert_outputs_with_color '
	' '
		\[31merror: can only pop '\''refs\/stash'\'' or entries of its reflog\[0?m
	'
}

assert_outputs__apply__no_such_commit() { # commit
	assert_outputs_with_color '
	' '
		\[31merror: no commit '\'"$(sanitize_for_sed "$1")"\''\[0?m
	'
}

assert_outputs__apply__no_operation_in_progress() { # operation
	assert_outputs_with_color '
	' '
		\[31merror: no '"$(sanitize_for_sed "$1")"' in progress\[0?m
	'
}

assert_outputs__apply__data_file_not_1_line() { # broken_op data_file
	assert_outputs_with_color '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		\[1;31mfatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' doesn'\''t have exactly 1 line\[0?m\n
		'"$(create_broken_operation_hint_regex)"'
	'
}

assert_outputs__apply__data_file_invalid_commit() { # broken_op data_file
	assert_outputs_with_color '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		\[1;31mfatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' contains an invalid commit hash\[0?m\n
		'"$(create_broken_operation_hint_regex)"'
	'
}

assert_outputs__apply__data_file_invalid_integer() { # broken_op data_file
	assert_outputs_with_color '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		\[1;31mfatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' doesn'\''t contain a positive integer\[0?m\n
		'"$(create_broken_operation_hint_regex)"'
	'
}

assert_outputs__apply__data_file_invalid_stash_number() { # broken_op data_file stash_number
	assert_outputs_with_color '
	' '
		'"$(create_broken_operation_header_regex "$1")"'\n
		\[1;31mfatal: '\''\.git\/'"$(sanitize_for_sed "$2")"\'' contains an invalid stash number\[0?m\n
		'"$(create_broken_operation_hint_regex)"'
	'
}

assert_outputs__apply__branch_already_used() { # current_op branch
	assert_outputs_with_color '
	' '
		\[1;31mfatal: failed to restore HEAD to initial position\[0?m\n
		\[1;31mfatal: '\'"$(sanitize_for_sed "$2")"\'' is already used by worktree at '\''.*'\''\[0?m\n
		\[33mhint: fix the problems and rerun '\''git istash --abort'\''\[0?m\n
		\[33mhint: or run '\''git istash --quit'\'' to forcefully cancel it\[0?m
	'
}

assert_outputs__apply__wrong_head_position_after_rebase() {
	assert_outputs_with_color '
	' '
		\[1;31mfatal: HEAD is not in the correct position after rebasing\[0?m
	'
}

assert_outputs__apply__no_rebase_in_progress() {
	assert_outputs_with_color '
	' '
		\[1;31mfatal: [Nn]o rebase in progress\??\[0?m
	'
}

assert_outputs__apply__no_rebase_in_progress_on_abort() { # operation
	assert_outputs_with_color '
	' '
		\[1;31mfatal: [Nn]o rebase in progress\??\[0?m\n
		Successfully aborted '\''git istash '"$(sanitize_for_sed "$1")"\''
	'
}

assert_outputs__apply__continue_abort() {
	assert_outputs_with_color '
	' '
		\[31merror: unclear whether to continue aborting or to abort continuing\[0?m
	'
}

assert_outputs__apply__continue_quit() {
	assert_outputs_with_color '
	' '
		\[31merror: unclear whether to continue quitting or to quit continuing\[0?m
	'
}

assert_outputs__apply__abort_quit() {
	assert_outputs_with_color '
	' '
		\[31merror: either abort or quit\; there is no middle road\[0?m
	'
}

assert_outputs__apply__continue_abort_quit() {
	assert_outputs_with_color '
	' '
		\[31merror: you can choose continue, abort or quit at your discretion but the rule is that you can only have one\[0?m
	'
}

assert_outputs__apply__wrong_number_of_stash_parents() { # stash_name
	assert_outputs_with_color '
	' '
		\[1;31mfatal: '\'"$(sanitize_for_sed "$1")"\'' doesn'\''t have 2 or 3 parents required to be a stash\[0?m
	'
}

assert_outputs__apply__wrong_number_of_untracked_stash_parents() { # stash_name
	assert_outputs_with_color '
	' '
		\[1;31mfatal: '\'"$(sanitize_for_sed "$1")"'\^3'\'' have parents unlike in a stash\[0?m
	'
}

assert_outputs__apply__wrong_number_of_staged_stash_parents() { # stash_name
	assert_outputs_with_color '
	' '
		\[1;31mfatal: '\'"$(sanitize_for_sed "$1")"'\^2'\'' doesn'\''t have one parent like in a stash\[0?m
	'
}

assert_outputs__apply__wrong_staged_stash_parent() { # stash_name
	assert_outputs_with_color '
	' '
		\[1;31mfatal: '\'"$(sanitize_for_sed "$1")"'\^1'\'' isn'\''t the parent of '\'"$(sanitize_for_sed "$1")"'\^2'\'' like in a stash\[0?m
	'
}

assert_outputs__apply__wrong_stash_commit_messages() { # stash_name
	assert_outputs_with_color '
	' '
		\[1;31mfatal: some of '\'"$(sanitize_for_sed "$1")"\'' commits don'\''t have correct messages for a stash\[0?m\n
		\[1;31mfatal: it may not be a stash entry or it may be damaged\[0?m
	'
}
