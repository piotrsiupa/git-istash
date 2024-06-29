#!/usr/bin/env sh

printf 'This script is not supposed to be run.\n'
#shellcheck disable=SC2016
printf 'If you want to use it IN a test, source it with the command:\n. ../commons.sh 1>/dev/null\n'
if [ -t 1 ] ; then exit 1 ; fi

# Note that this script sets terminal to exit upon encountering any error.
# Note that the arguments of these functions are not validated. Familiarize youself with them before trying to use them.

set -e

capture_outputs() { # command [arguments...]
	stdout_pipe_file="$(mktemp)"
	stderr_pipe_file="$(mktemp)"
	exec 6>&1
	error_code="$(
		set +e
		{
			{
				{
					"$@" 7>&2 2>&1 1>&7 7>&-
					printf '%i\n' $? 1>&6
				} | tee "$stderr_pipe_file"
			} 7>&2 2>&1 1>&7 7>&- | tee "$stdout_pipe_file"
		} 7>&6 6>&1 1>&7 7>&-
	)"
	exec 6>&-
	#shellcheck disable=SC2034
	stdout="$(cat <"$stdout_pipe_file")"
	rm "$stdout_pipe_file"
	#shellcheck disable=SC2034
	stderr="$(cat <"$stderr_pipe_file")"
	rm "$stderr_pipe_file"
	return "$error_code"
}

assert_success() { # command [arguments...]
	"$@"
}

assert_failure() { # command [arguments...]
	if "$@" ; then return 1 ; fi
}

assert_conflict_message() { #
	test "$(printf '%s' "$stderr" | tail -n4)" = '
hint: Disregard all hints above about using "git rebase".
hint: Use "git unstash --continue" after fixing conflicts.
hint: To abort and get back to the state before "git unstash", run "git unstash --abort".'
}

assert_tracked_files() { # expected
	test "$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')" = "$1"
}

assert_status() { # expected
	test "$(git status --porcelain | head -c -1 | tr '\n' '|')" = "$1"
}

assert_file_contents() { # file expected_current [expected_staged]
	test "$(cat "$1")" = "$2"
	if [ $# -eq 3 ]
	then
		test "$(git show ":$1")" = "$3"
	fi
}

assert_stash_count() { # expected
	test "$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)" -eq "$1"
}

assert_log_length() { # expected
	test "$(git rev-list --count HEAD)" -eq "$1"
}

assert_branch_count() { # expected
	test "$(git for-each-ref refs/heads --format='x' | wc -l)" -eq "$1"
}

assert_head_hash() { # expected
	test "$(git rev-parse HEAD)" = "$1"
}

assert_stash_hash() { # stash_num expected
	test "$(git rev-parse "stash@{\1}")" = "$2"
}

assert_head_name() { # expected
	if printf '%s' "$1" | grep -q '^~'
	then
		if git rev-parse HEAD ; then exit 1 ; fi
		test "$(git branch --show-current)" = "$(printf '%s' "$1" | cut -c2-)"
	else
		test "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" = "$1"
	fi
}
