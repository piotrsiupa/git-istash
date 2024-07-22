#!/usr/bin/env sh

set -e

print_help() {
	printf '%s - Script that runs tests from sub-directories of this directory.\n' "$(basename "$0")"
	printf '\n'
	printf 'Usage: %s [<options>] [--] [<filter>...]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help message end exit.\n'
	printf '\t--version\t- Print version information and exit.\n'
	printf '    -f, --failed\t- Rerun only the tests that failed the last time when\n\t\t\t  they were run. (Check the presence of the test dir.)\n'
	printf '    -d, --debug\t\t- Print outputs of all commands in run in the tests.\n'
	printf '    -q, --quiet\t\t- Don'\''t print summaries for passed tests.\n'
	printf '    -c, --color=when\t- Set color mode (always / never / auto).\n'
	printf '        --raw-name\t- Print paths to test files instead of prettified names.\n'
	printf '    -l, --limit=number\t- Set maximum number of tests to be run. (It pairs well\n\t\t\t  with "--failed" to e.g. rerun the first failed test.)\n'
	printf '\n'
	printf 'Filters:\n'
	printf 'You can specify one or more filters in the command call. '
	printf 'The filters are BRE\nregexps that match test names that should be run. '
	printf '(A test name is the name of\nthe inluding the sub-directory but without the file extension.) '
	printf 'A test will be\nrun if it matches any of the filters. '
	printf 'If there are no filters, all tests are\nrun. '
	printf 'This can be used to either list individual tests or choose some categories.\n'
	printf '(See "README.md" in the test directory for more information about test names.)\n'
}

print_version() {
	printf 'test script version 1.0.0\n'
}

print_color_code() { # code
	if [ "$use_color" = y ]
	then
		#shellcheck disable=SC2059
		printf "$1"
	fi
}
print_centered() { # text character
	padding_size=$((80 - 2 - ${#1}))
	printf -- "$2%.0s" $(seq 1 $((padding_size / 2)))
	printf -- ' %s ' "$1"
	printf -- "$2%.0s" $(seq 1 $((padding_size - (padding_size / 2))))
}

get_test_script() { # test_name
	printf '%s.sh' "$1"
}
get_test_dir() { # test_name
	printf '%s/t_dir__%s' "$(basename "$(dirname "$1")")" "$(basename "$1")"
}

cleanup_test() { # test_name
	rm -rf "$(get_test_dir "$1")"
}
create_test_dir() { # test_name
	test_dir="$(get_test_dir "$1")"
	mkdir "$test_dir"
}

find_tests() { # pattern
	find . -mindepth 2 -maxdepth 2 -type f -name '*.sh' \
	| sed 's;^\./\(.*\)\.sh$;\1;' \
	| grep "$1" \
	| while read -r test_name
	do
		if [ "$only_failed" = n ] || [ -d "$(get_test_dir "$test_name")" ]
		then
			printf '%s\n' "$test_name"
		fi
	done \
	| sort \
	| if [ "$test_limit" -eq 0 ]
	then
		cat
	else
		head -n "$test_limit"
	fi
}

run_test() { # test_name
	cleanup_test "$1"
	create_test_dir "$1" 1>/dev/null
	exec 5>&1
	test_passed="$(
		exec 3>&2
		{
			{
				export WAS_IT_CALLED_FROM_RUN_SH='indeed'
				if ! cd "$(get_test_dir "$1")"
				then
					printf '0' 1>&5
				elif [ "$debug_mode" = n ]
				then
					if sh "../$(basename "$(get_test_script "$1")")" 1>/dev/null 2>&1
					then
						printf y 1>&5
					else
						printf n 1>&5
					fi
				else
					{
						if sh "../$(basename "$(get_test_script "$1")")"
						then
							printf y 1>&5
						else
							printf n 1>&5
						fi 6>&2 2>&1 1>&6 6>&- \
						| if [ "$use_color" = y ]
						then
							$sed_call 's/^.*$/\t'"$esc_char"'[31m&'"$esc_char"'[39m/'
						else
							$sed_call 's/^/\t/'
						fi
					} 6>&2 2>&1 1>&6 6>&- | $sed_call 's/^/\t/'
				fi 6>&5 5>&1 1>&6 6>&-
			} 6>&3 3>&1 1>&6 6>&- \
			| if [ "$use_color" = y ]
			then
				$sed_call 's/^.*$/\t'"$esc_char"'[1;31mFailed assertion:'"$esc_char"'[22m &'"$esc_char"'[39m/'
			else
				$sed_call 's/^/\tFailed assertion: /'
			fi
		} 6>&3 3>&1 1>&6 6>&-
		exec 3>&-
	)"
	exec 5>&-
	if [ "$raw_name" = n ]
	then
		display_name="\"$(printf '%s' "$1" | tr '_' ' ')\""
	else
		display_name="$(dirname "$0")/$1.sh"
	fi
	if [ "$test_passed" = y ]
	then
		if [ "$quiet_mode" = n ]
		then
			print_color_code '\033[0;1;32m'
			printf 'PASSED - %s' "$display_name"
			print_color_code '\033[22;39m'
			printf '\n'
		fi
		cleanup_test "$1"
		return 0
	else
		print_color_code '\033[0;1;31m'
		printf 'FAILED - %s' "$display_name"
		print_color_code '\033[22;39m'
		printf ' (the result is kept)\n'
		return 1
	fi
}
run_tests() {
	if printf '' | sed --unbuffered 's/^/x/' 1>/dev/null 2>&1
	then
		sed_call='sed --unbuffered'
	else
		sed_call='sed'
	fi
	esc_char="$(printf '\033')"
	exec 4>&1
	passed_tests="$(
		previous_category=''
		printf '%s\n' "$tests" \
		| while read -r test_name
		do
			current_category="$(dirname "$test_name")"
			if [ "$current_category" != "$previous_category" ]
			then
				previous_category="$current_category"
				{
					print_color_code '\033[1m'
					print_centered "$current_category" '-'
					print_color_code '\033[22m'
					printf '\n'
				} 1>&4
				printf '%s\n' "$current_category"
			fi
			if run_test "$test_name" 1>&4
			then
				printf '%s\n' "$current_category"
			fi
		done | uniq -c | awk '{print $1 - 1}'
	)"
	exec 4>&-
}

print_summary() {
	print_color_code '\033[1m'
	print_centered 'Results' '='
	print_color_code '\033[22m'
	printf '\n'
	i=0
	printf '%s\n' "$tests" | xargs -rn1 -- dirname | uniq -c | awk '{$1=$1;print}' \
	| while read -r category
	do
		i=$((i + 1))
		total_in_category="$(printf '%s\n' "$category" | cut -d' ' -f1)"
		passed_in_category="$(printf '%s' "$passed_tests" | head -n $i | tail -n 1)"
		printf '%s: ' "$(printf '%s' "$category" | cut -d' ' -f2)"
		if [ "$passed_in_category" -eq "$total_in_category" ]
		then
			print_color_code '\033[1;32;4m'
			printf 'Passed all %i tests.' "$total_in_category"
		else
			print_color_code '\033[1;31;4m'
			printf 'Passed %i out of %i tests.' "$passed_in_category" "$total_in_category"
		fi
		print_color_code '\033[0m'
		printf '\n'
	done
	passed_tests=$(($(printf '%s' "$passed_tests" | tr '\n' '+')))
	total_tests="$(printf '%s\n' "$tests" | wc -l)"
	if [ "$total_tests" -ne 0 ]
	then
		if [ "$passed_tests" -eq "$total_tests" ]
		then
			print_color_code '\033[42;1;37;4m'
			printf 'Passed all %i tests.' "$total_tests"
		else
			print_color_code '\033[41;30;4m'
			printf 'Passed %i out of %i tests.' "$passed_tests" "$total_tests"
		fi
	else
		print_color_code '\033[43;1;33;4m'
		printf 'No matching tests were found!'
	fi
	print_color_code '\033[0m'
	printf '\n'
}

getopt_result="$(getopt -o'hfdqc:l:' --long='help,version,failed,debug,quiet,color:,raw,raw-name,file-name,limit:' -n"$(basename "$0")" -- "$@")"
eval set -- "$getopt_result"
only_failed=n
debug_mode=n
quiet_mode=n
use_color='auto'
raw_name=n
test_limit=0
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
		;;
	--version)
		print_version
		exit 0
		;;
	-f|--failed)
		only_failed=y
		;;
	-d|--debug)
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
	-l|--limit)
		shift
		if [ "$1" -eq "$1" ] 2>/dev/null && [ "$1" -ge 0 ]
		then
			test_limit="$1"
		else
			printf '"%s" is not a valid number of tests (a non-negative integer).\n' "$1" 1>&2
			exit 1
		fi
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
	filter="\\($1\\)"
	shift
	while [ $# -ne 0 ]
	do
		filter="$filter\\|\\($1\\)"
		shift
	done
fi

cd "$(dirname "$0")"
cd '../bin'
PATH="$(pwd):$PATH"
cd "$OLDPWD"
export PATH
tests="$(find_tests "$filter")"
run_tests
print_summary
[ "$total_tests" -ne 0 ] && [ "$passed_tests" -eq "$total_tests" ]
