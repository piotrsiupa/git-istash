#!/usr/bin/env sh

set -e

cd "$(dirname "$0")"
scripts_dir='../scripts'

get_test_script() { # test_name
	printf 'test_%s.sh' "$1"
}
get_test_dir() { # test_name
	printf 't_dir_%s' "$1"
}

cleanup_test() { # test_name
	rm -rf "$(get_test_dir "$1")"
}
create_test_dir() { # test_name
	test_dir="$(get_test_dir "$1")"
	git init --initial-branch=master "$test_dir"
	git -C "$test_dir" config --local user.email 'test@localhost'
	git -C "$test_dir" config --local user.name 'test'
	git -C "$test_dir" commit --allow-empty -m 'Initial commit'
}

find_tests() { # pattern
	find . -maxdepth 1 -type f -name 'test_*.sh' -print0 \
	| xargs -r0n1 -- basename | rev | cut -c4- | rev | cut -c6- \
	| grep -P "$1" \
	| sort
}

run_test() { # test_name
	cleanup_test "$1"
	create_test_dir "$1" 1>/dev/null
	if [ "$debug" -eq 0 ]
	then
		test_passed=0
		if "./$(get_test_script "$1")" "$(get_test_dir "$1")" 1>/dev/null 2>&1
		then
			test_passed=1
		fi
	else
		pipe_file="$(mktemp -u)"
		mkfifo "$pipe_file"
		exec 4<>"$pipe_file"
		rm "$pipe_file"
		{
			if "./$(get_test_script "$1")" "$(get_test_dir "$1")"
			then
				printf '1\n' 1>&4
			else
				printf '0\n' 1>&4
			fi 5>&2 2>&1 1>&5 5>&- \
			| if [ -t 1 ]
			then
				sed -u 's/^.*$/\t\x1B[31m&\x1B[39m/'
			else
				sed -u 's/^/\t/'
			fi
		} 5>&2 2>&1 1>&5 5>&- | sed -u 's/^/\t/'
		read -r test_passed <&4
		exec 4>&-
	fi
	if [ "$test_passed" -ne 0 ]
	then
		printf '\e[0;1;32m'
		printf 'PASSED - "%s"' "$(printf '%s' "$1" | tr '_' ' ')"
		printf '\e[22;39m\n'
		cleanup_test "$1"
		return 0
	else
		printf '\e[0;1;31m'
		printf 'FAILED - "%s"' "$(printf '%s' "$1" | tr '_' ' ')"
		printf '\e[22;39m'
		printf ' (the result is kept)\n'
		return 1
	fi
}
run_tests() { # pattern
	pipe_file="$(mktemp -u)"
	mkfifo "$pipe_file"
	exec 3<>"$pipe_file"
	rm "$pipe_file"
	find_tests "$1" \
	| while read -r test_name
	do
		if run_test "$test_name"
		then
			printf '1' 1>&3
		fi
	done
	printf '\n' 1>&3
	passed_tests="$(head -n 1 <&3 | tr -d '\n' | wc -c)"
	exec 3>&-
}

print_summary() {
	if [ "$total_tests" -ne 0 ]
	then
		if [ "$passed_tests" -eq "$total_tests" ]
		then
			printf '\e[42;1;32;4m'
			printf 'Passed all %i tests.' "$total_tests"
		else
			printf '\e[41;2;31;4m'
			printf 'Passed %i out of %i tests.' "$passed_tests" "$total_tests"
		fi
	else
		printf '\e[43;1;33;4m'
		printf 'No matching tests were found!'
	fi
	printf '\e[0m'
	printf '\n'
}

debug=0
if [ "$1" = '--debug' ]
then
	debug=1
	shift
fi
if [ $# -eq 0 ]
then
	filter=''
else
	filter="($1)"
	shift
	while [ $# -ne 0 ]
	do
		filter="$filter|($1)"
		shift
	done
fi

test -d "$scripts_dir"
PATH="$(realpath "$scripts_dir"):$PATH"
total_tests="$(find_tests "$filter" | wc -l)"
export PATH
run_tests "$filter"
print_summary
