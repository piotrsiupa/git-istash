#!/usr/bin/env sh

printf 'This script is not supposed to be run.\n'
#shellcheck disable=SC2016
printf 'If you want to use it IN a test, source it with the command:\n. ../commons.sh 1>/dev/null\n'
if [ -t 1 ] ; then exit 1 ; fi

set -e

run_and_capture() { # command [arguments...]
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
