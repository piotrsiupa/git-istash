#!/usr/bin/env sh

printf 'This script is not supposed to be run.\n'
printf 'If you want to use it IN a test, source it with the command:\n. ../commons.sh 1>/dev/null\n'
if [ -t 1 ] ; then exit 1 ; fi

# Note that this script sets terminal to exit upon encountering any error.
# Note that the arguments of these functions are not validated. Familiarize youself with them before trying to use them.
# Note that streams 4..8 are used by scripts (here and in `run.sh`) and they shouldn't be touched. (Stream is used to print assertion errors and you can write to it.)

set -e

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

assert_success() { # command [arguments...]
	if ! "$@"
	then
		printf 'Command %s returned a non-0 exit code!\n' "$(command_to_string "$@")" 1>&3
		return 1
	fi
}

assert_failure() { # command [arguments...]
	if "$@"
	then
		printf 'Command %s returned exit code 0!\n' "$(command_to_string "$@")" 1>&3
		return 1
	fi
}

assert_conflict_message() { # command [arguments...]
	if [ "$(printf '%s' "$stderr" | tail -n4)" != '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".' ]
	then
		printf 'Command %s didn'\''t print the correct conflict message!\n' "$(command_to_string "$@")" 1>&3
		return 1
	fi
}

assert_tracked_files() { # expected
	value_for_assert="$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')"
	if [ "$value_for_assert" != "$1" ]
	then
		printf 'Expected tracked files to be "%s" but they are "%s"!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_status() { # expected
	value_for_assert="$(git status --porcelain | head -c -1 | tr '\n' '|')"
	if [ "$value_for_assert" != "$1" ]
	then
		printf 'Expected repository status to be "%s" but it is "%s"!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_file_contents() { # file expected_current [expected_staged]
	value_for_assert="$(cat "$1")"
	if [ "$value_for_assert" != "$2" ]
	then
		printf 'Expected content of file "%s" to be "%s" but it is "%s"!\n' "$1" "$2" "$value_for_assert" 1>&3
		return 1
	fi
	if [ $# -eq 3 ]
	then
		value_for_assert="$(git show ":$1")"
		if [ "$value_for_assert" != "$3" ]
		then
			printf 'Expected staged content of file "%s" to be "%s" but it is "%s"!\n' "$1" "$3" "$value_for_assert" 1>&3
			return 1
		fi
	fi
	unset value_for_assert
}

assert_stash_count() { # expected
	value_for_assert="$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)"
	if [ "$value_for_assert" -ne "$1" ]
	then
		printf 'Expected number of stashes to be %i but it is %i!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_log_length() { # expected
	value_for_assert="$(git rev-list --count HEAD)"
	if [ "$value_for_assert" -ne "$1" ]
	then
		printf 'Expected lenght of HEAD'\''s history to be %i but it is %i!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_branch_count() { # expected
	value_for_assert="$(git for-each-ref refs/heads --format='x' | wc -l)"
	if [ "$value_for_assert" -ne "$1" ]
	then
		printf 'Expected number of branches to be %i but it is %i!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_head_hash() { # expected
	value_for_assert="$(git rev-parse HEAD)"
	if [ "$value_for_assert" != "$1" ]
	then
		printf 'Expected HEAD to be at %s but it is at %s!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_stash_hash() { # stash_num expected
	value_for_assert="$(git rev-parse "stash@{$1}")"
	if [ "$value_for_assert" != "$2" ]
	then
		printf 'Expected stash entry #%i to be %s but it is %s!\n' "$1" "$2" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_head_name() { # expected
	if printf '%s' "$1" | grep -q '^~'
	then
		set -- "$(printf '%s' "$1" | cut -c2-)"
		if git rev-parse HEAD 1>/dev/null 2>&1
		then
			printf 'Expected HEAD to be an orphan!\n' 1>&3
			return 1
		fi
		value_for_assert="$(git branch --show-current)"
	else
		if ! git rev-parse HEAD 1>/dev/null 2>&1
		then
			printf 'Didn'\''t expect HEAD to be an orphan!\n' 1>&3
			return 1
		fi
		value_for_assert="$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)"
	fi
	if [ "$value_for_assert" != "$1" ]
	then
		printf 'Expected the name of HEAD branch be "%s" but it is "%s"!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}
