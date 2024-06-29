#!/usr/bin/env sh

set -e

print_help() {
	printf '%s - Script that runs tests from this directory.\n' "$(basename "$0")"
	printf '\n'
	printf 'Usage: %s [<options>] [--] [<filter>...]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help message.\n'
	printf '    -f, --failed\t- Rerun only the tests that failed the last time when\n\t\t\t  they were run. (Check the presence of the test dir.)\n'
	printf '        --debug\t\t- Print outputs of all commands in run in the tests.\n'
	printf '    -q, --quiet\t\t- Don'\''t print summaries for passed tests.\n'
	printf '    -c, --color=when\t- Set color mode (always / never / auto).\n'
	printf '        --raw-name\t- Print paths to test files instead of prettified names.\n'
	printf '\n'
	printf 'Filters:\n'
	printf 'You can specify one or more filters in the command call. '
	printf 'The filters are PCRE\nregexps that match test names that should be run. '
	printf '(A test name is the name of\nthe file without the prefix "test_" and the file extension.) '
	printf 'A test will be run\nif it matches any of the filters. '
	printf 'If there are no filters, all tests are run.\n'
	printf 'This can be used to either list individual tests or filter out some categories.\n'
	printf '(See "README.md" in the test directory for more information about test names.)\n'
}

print_color_code() { # code
	if [ "$use_color" = y ]
	then
		#shellcheck disable=SC2059
		printf "$1"
	fi
}

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
	| xargs -r0n1 -- basename | sed 's/^test_\(.*\)\.sh$/\1/' \
	| grep -P "$1" \
	| while read -r test_name
	do
		if [ "$only_failed" = n ] || [ -d "$(get_test_dir "$test_name")" ]
		then
			printf '%s\n' "$test_name"
		fi
	done \
	| sort
}

run_test() { # test_name
	cleanup_test "$1"
	create_test_dir "$1" 1>/dev/null
	exec 5>&1
	test_passed="$(
		exec 3>&2
		{
			{
				if ! cd "$(get_test_dir "$1")"
				then
					printf '0' 1>&5
				elif [ "$debug_mode" = n ]
				then
					if sh "../$(get_test_script "$1")" 1>/dev/null 2>&1
					then
						printf y 1>&5
					else
						printf n 1>&5
					fi
				else
					{
						if sh "../$(get_test_script "$1")"
						then
							printf y 1>&5
						else
							printf n 1>&5
						fi 6>&2 2>&1 1>&6 6>&- \
						| if [ "$use_color" = y ]
						then
							sed -u 's/^.*$/\t\x1B[31m&\x1B[39m/'
						else
							sed -u 's/^/\t/'
						fi
					} 6>&2 2>&1 1>&6 6>&- | sed -u 's/^/\t/'
				fi 6>&5 5>&1 1>&6 6>&-
			} 6>&3 3>&1 1>&6 6>&- \
			| if [ "$use_color" = y ]
			then
				sed -u 's/^.*$/\t\x1B[1;31mFailed assertion:\x1B[22m &\x1B[39m/'
			else
				sed -u 's/^/\tFailed assertion: /'
			fi
		} 6>&3 3>&1 1>&6 6>&-
		exec 3>&-
	)"
	exec 5>&-
	if [ "$raw_name" = n ]
	then
		display_name="\"$(printf '%s' "$1" | tr '_' ' ')\""
	else
		display_name="$(dirname "$0")/test_$1.sh"
	fi
	if [ "$test_passed" = y ]
	then
		if [ "$quiet_mode" = n ]
		then
			print_color_code '\e[0;1;32m'
			printf 'PASSED - %s' "$display_name"
			print_color_code '\e[22;39m'
			printf '\n'
		fi
		cleanup_test "$1"
		return 0
	else
		print_color_code '\e[0;1;31m'
		printf 'FAILED - %s' "$display_name"
		print_color_code '\e[22;39m'
		printf ' (the result is kept)\n'
		return 1
	fi
}
run_tests() { # pattern
	exec 4>&1
	passed_tests="$(
		find_tests "$1" \
		| while read -r test_name
		do
			if run_test "$test_name" 1>&4
			then
				printf '1'
			fi
		done | head -n 1 | wc -c
	)"
	exec 4>&-
}

print_summary() {
	if [ "$total_tests" -ne 0 ]
	then
		if [ "$passed_tests" -eq "$total_tests" ]
		then
			print_color_code '\e[42;1;37;4m'
			printf 'Passed all %i tests.' "$total_tests"
		else
			print_color_code '\e[41;30;4m'
			printf 'Passed %i out of %i tests.' "$passed_tests" "$total_tests"
		fi
	else
		print_color_code '\e[43;1;33;4m'
		printf 'No matching tests were found!'
	fi
	print_color_code '\e[0m'
	printf '\n'
}

getopt_result="$(getopt -o'hfqc:' --long='help,failed,debug,quiet,color:,raw,raw-name,file-name' -n"$(basename "$0")" -- "$@")"
eval set -- "$getopt_result"
only_failed=n
debug_mode=n
quiet_mode=n
use_color='auto'
raw_name=n
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
		;;
	--failed)
		only_failed=y
		;;
	--debug)
		debug_mode=y
		;;
	-q|--quiet)
		quiet_mode=y
		;;
	-c|--color)
		shift
		if printf '%s' "$1" | grep -ixq 'auto\|default'
		then
			use_color='auto'
		elif printf '%s' "$1" | grep -ixq 'y\|yes\|always\|true\|1'
		then
			use_color=y
		elif printf '%s' "$1" | grep -ixq 'n\|no\|never\|false\|0'
		then
			use_color=n
		else
			printf '"%s" is not a valid color setting. (always / never / auto)\n' "$1" 1>&2
			exit 1
		fi
		;;
	--raw|--raw-name|--file-name)
		raw_name=y
		;;
	--)
		shift
		break
		;;
	esac
	shift
done
if [ "$use_color" = 'auto' ]
then
	if [ -t 1 ] && [ -t 2 ]
	then
		use_color=y
	else
		use_color=n
	fi
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

cd "$(dirname "$0")"
scripts_dir='../scripts'
test -d "$scripts_dir"
PATH="$(realpath "$scripts_dir"):$PATH"
export PATH
total_tests="$(find_tests "$filter" | wc -l)"
run_tests "$filter"
print_summary
[ "$total_tests" -ne 0 ] && [ "$passed_tests" -eq "$total_tests" ]
