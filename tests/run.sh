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
	printf '    -r, --raw-name\t- Print paths to test files instead of prettified names.\n'
	printf '    -l, --limit=number\t- Set maximum number of tests to be run. (It pairs well\n\t\t\t  with "--failed" to e.g. rerun the first failed test.)\n'
	printf '    -p, --print-paths\t- Instead of running tests, print their paths and exit.\n\t\t\t  (The paths are relative to the directory "tests".)\n'
	printf '    -j, --jobs=N\t- Run N tests in parallel. (default is sequentially)\n\t\t\t  N=0 uses all available processing units. ("nproc")\n'
	printf '\n'
	printf 'Filters:\n'
	printf 'You can specify one or more filters in the command call. '
	printf 'The filters are BRE\nregexps that match test names that should be run. '
	printf '(A test name is the name of\nthe inluding the sub-directory but without the file extension.) '
	printf 'A test will be\nrun if it matches any of the filters. '
	printf 'If there are no filters, all tests are\nrun. '
	printf 'This can be used to either list individual tests or choose some categories.\n'
	printf '(See "README.md" in the test directory for more information about test names.)\n'
	printf 'Paths to specific test files are also accepted.\n'
}

print_version() {
	printf 'test script version 1.3.0\n'
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
	error_count=0
	PARAMETERS_FILE="$(mktemp)"
	export PARAMETERS_FILE
	for i in $(seq 1 1000)
	do
		ROTATE_PARAMETER=y
		export ROTATE_PARAMETER
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
		if [ -n "$(cat "$PARAMETERS_FILE")" ]
		then
			display_name="$display_name ($(awk '{print $2}' "$PARAMETERS_FILE" | sed 's/$/, /' | head -c-3 | tr -d '\n'))"
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
		else
			print_color_code '\033[0;1;31m'
			printf 'FAILED - %s' "$display_name"
			print_color_code '\033[22;39m'
			printf ' (the result is kept)\n'
			error_count=$((error_count + 1))
		fi
		if [ -n "$(cat "$PARAMETERS_FILE")" ]
		then
			test_dir="$(get_test_dir "$1")"
			parametrized_test_dir="${test_dir}__$(awk '{print $2}' "$PARAMETERS_FILE" | head -c-1 | tr '\n' '_')"
			rm -rf "$parametrized_test_dir"
			if [ -e "$test_dir" ]
			then
				mv "$test_dir" "$parametrized_test_dir"
			fi
		fi
		if [ -z "$(awk '$2 != $3 { print 1 }' "$PARAMETERS_FILE")" ]
		then
			break
		fi
	done
	rm "$PARAMETERS_FILE"
	test "$error_count" -eq 0
}
update_current_category() { # test_name
	current_category="$(dirname "$1")"
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
}
run_tests() {
	if [ -z "$tests" ]
	then
		return 0
	fi
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
		| if [ "$jobs_num" -eq 1 ]
		then
			while read -r test_name
			do
				update_current_category "$test_name"
				if run_test "$test_name" 1>&4
				then
					printf '%s\n' "$current_category"
				fi
			done
		else
			running_tests_count=0
			running_tests_data=''
			while true
			do
				while [ $running_tests_count -ne "$jobs_num" ]
				do
					if ! read -r test_name
					then
						break
					fi
					result_file="$(mktemp)"
					{ run_test "$test_name" && printf '0\n' || printf '1\n' ; } 1>"$result_file" 2>&1 &
					running_tests_count=$((running_tests_count + 1))
					running_tests_data="$(printf '%s\n%i %s %s' "$running_tests_data" $! "$result_file" "$test_name" | sed '/^\s*$/ d')"
				done
				update_current_category "$(printf '%s\n' "$running_tests_data" | head -n1 | cut -d' ' -f3-)"
				wait "$(printf '%s\n' "$running_tests_data" | head -n 1 | cut -d' ' -f1)"
				result_file="$(printf '%s\n' "$running_tests_data" | head -n 1 | cut -d' ' -f2)"
				head -n-1 "$result_file" \
				| while IFS= read -r line
				do
					if printf '%s' "$line" | grep -q '^\t'
					then
						printf '%s\n' "$line" 1>&2
					else
						printf '%s\n' "$line" 1>&4
					fi
				done
				if [ "$(tail -n1 "$result_file")" = '0' ]
				then
					printf '%s\n' "$current_category"
				fi
				rm -f "$result_file"
				running_tests_count=$((running_tests_count - 1))
				running_tests_data="$(printf '%s\n' "$running_tests_data" | tail -n+2)"
				if [ $running_tests_count -eq 0 ]
				then
					break
				fi
			done
		fi \
		| uniq -c | awk '{print $1 - 1}'
	)"
	exec 4>&-
}

print_summary() {
	print_color_code '\033[1m'
	print_centered 'Results' '='
	print_color_code '\033[22m'
	printf '\n'
	if [ -n "$tests" ]
	then
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
				if [ "$total_in_category" -eq 1 ]
				then
					printf 'Passed the test.'
				else
					printf 'Passed all %i tests.' "$total_in_category"
				fi
			else
				print_color_code '\033[1;31;4m'
				if [ "$total_in_category" -eq 1 ]
				then
					printf 'Failed the test.'
				else
					printf 'Passed %i out of %i tests.' "$passed_in_category" "$total_in_category"
				fi
			fi
			print_color_code '\033[0m'
			printf '\n'
		done
	fi
	if [ -z "$tests" ]
	then
		passed_tests=0
		total_tests=0
	else
		passed_tests=$(($(printf '%s' "$passed_tests" | tr '\n' '+')))
		total_tests="$(printf '%s\n' "$tests" | wc -l)"
	fi
	if [ "$total_tests" -ne 0 ]
	then
		if [ "$passed_tests" -eq "$total_tests" ]
		then
			print_color_code '\033[42;1;37;4m'
			if [ "$total_tests" -eq 1 ]
			then
				printf 'Passed the test.'
			else
				printf 'Passed all %i tests.' "$total_tests"
			fi
		else
			print_color_code '\033[41;30;4m'
			if [ "$total_tests" -eq 1 ]
			then
				printf 'Failed the test.'
			else
				printf 'Passed %i out of %i tests.' "$passed_tests" "$total_tests"
			fi
		fi
	else
		print_color_code '\033[43;1;33;4m'
		printf 'No matching tests were found!'
	fi
	print_color_code '\033[0m'
	printf '\n'
}

getopt_result="$(getopt -o'hfdqc:rl:pj:' --long='help,version,failed,debug,quiet,color:,raw,raw-name,file-name,limit:,print-paths,jobs:' -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
only_failed=n
debug_mode=n
quiet_mode=n
use_color='auto'
raw_name=n
test_limit=0
print_paths=n
jobs_num=1
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
	-r|--raw|--raw-name|--file-name)
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
	-p|--print-paths)
		print_paths=y
		;;
	-j|--jobs)
		shift
		if [ "$1" -eq "$1" ] 2>/dev/null && [ "$1" -ge 0 ]
		then
			if [ "$1" -eq 0 ]
			then
				jobs_num="$(nproc)"
			else
				jobs_num="$1"
			fi
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

normalize_filter_entry() { # filter_entry
	if [ -f "$1" ]
	then
		printf '%s' "$1" \
		| sed -e 's;^.*/\([^/]\+/[^/]\+\)$;\1;' \
			-e 's;^[^/]\+$;./&;' \
			-e "s;^\\./;$(basename "$(pwd)")/;" \
			-e 's/\.sh$//' \
			-e 's/^/^/'
	else
		printf '%s' "$1"
	fi
}
if [ $# -eq 0 ]
then
	filter=''
else
	filter="\\($(normalize_filter_entry "$1")\\)"
	shift
	while [ $# -ne 0 ]
	do
		filter="$filter\\|\\($(normalize_filter_entry "$1")\\)"
		shift
	done
fi

cd "$(dirname "$0")"
tests="$(find_tests "$filter")"
if [ "$print_paths" = y ]
then
	printf '%s' "$tests" | xargs -- printf '%s.sh\n'
	exit 0
fi

cd '../bin'
PATH="$(pwd):$PATH"
cd "$OLDPWD"
export PATH
run_tests
print_summary
[ "$total_tests" -ne 0 ] && [ "$passed_tests" -eq "$total_tests" ]
