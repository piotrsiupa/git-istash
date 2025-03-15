#!/usr/bin/env sh

set -e

print_help() {
	printf '%s - Script that runs tests from sub-directories of this directory.\n' "$(basename "$0")"
	printf '\n'
	printf 'Usage: %s [<options>] [--] [<filter>...]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help message end exit.\n'
	printf '    -c, --color=when\t- Set color mode (always / never / auto).\n'
	printf '    -d, --debug\t\t- Print outputs of all commands in run in the tests.\n'
	printf '    -f, --failed\t- Rerun only the tests that failed the last time when\n\t\t\t  they were run. (Check the presence of the test dir.)\n'
	printf '    -j, --jobs=N\t- Run N tests in parallel. (default is sequentially)\n\t\t\t  N=0 uses all available processing units. ("nproc")\n'
	printf '    -l, --limit=number\t- Set maximum number of tests to be run. (It pairs well\n\t\t\t  with "--failed" to e.g. rerun the first failed test.)\n'
	printf '    -m, --meticulous=N\t- Set how many tests will be run. Allowed values are\n\t\t\t  0..5 (default=3). (See the section "Meticulousness".)\n'
	printf '    -p, --print-paths\t- Instead of running tests, print their paths and exit.\n\t\t\t  (The paths are relative to the directory "tests".)\n'
	printf '    -q, --quiet\t\t- Don'\''t print summaries for passed tests.\n'
	printf '    -Q, --quieter\t- Don'\''t print summaries for known failures either.\n'
	printf '    -r, --raw-name\t- Print paths to test files instead of prettified names.\n'
	printf '    -v, --verbose\t- Show each set of parameters even of if passes.\n'
	printf '\t--version\t- Print version information and exit.\n'
	printf '\n'
	printf 'Filters:\n'
	printf 'You can specify one or more filters in the command call. '
	printf 'The filters are ERE\nregexps that match test names that should be run. '
	printf '(A test name is the name of\nthe inluding the sub-directory but without the file extension.) '
	printf 'A test will be\nrun if it matches any of the filters. '
	printf 'If there are no filters, all tests are\nrun. '
	printf 'This can be used to either list individual tests or choose some categories.\n'
	printf '(See "README.md" in the test directory for more information about test names.)\n'
	printf 'Paths to specific test files are also accepted.\n'
	printf '\n'
	printf 'Meticulousness:\n'
	printf 'This controls the balance between the speed and how detailed the tests are.\n'
	printf 'The exact metrics depend strongly on which specific tests are run.\n'
	printf 'The levels are:\n'
	printf '    0 - Most of the tests (marked as non-essential) are skipped. It can be used\n\tto check if the most important functionality is implemented but it'\''s\n\tnot very useful overall. (Extremely fast, though.)\n'
	printf '    1 - Only the first set of parameters is run for each parametric test. Almost\n\tall tests are parametric so a lot is skipped but this should suffice to\n\tdo a quick test. It won'\''t catch most of the corner cases, though.\n'
	printf '    2 - When an option has a few spellings (e.g. "-m" and "--message") only one\n\tof them will be tested. Beside that, other things from parametric tests\n\tare tested in all combinations, except not all the ways to specify\n\tpathspecs because there is a lot. (Null-separated stdin and non-null-\n\t-separated file are skipped but it probably should still test all\n\texecution paths.) This is relatively thorough and it should be enough\n\tfor testing on the fly, while writing code.\n'
	printf '    3 - When an option has multiple spellings, all of them are tested but not\n\tnecessarily all combinations of spellings of different options.\n\tThis level should be run before every commit!\n'
	printf '    4 - All combinations of parameters are run in parametric tests.\n\t(A bit of an overkill but it is run from time to time, just to be sure.)\n'
	printf '    5 - All combinations of parameters are run in parametric tests plus non\n\tstandard versions of options are tested (e.g. "--mess" instead of\n\t"--message"). (It'\''s definitely an overkill and it takes really long.)\n'
}

print_version() {
	printf 'test script version 1.3.0\n'
}

printf_color_code() { # code_for_printf...
	if [ "$use_color" = y ]
	then
		#shellcheck disable=SC2059
		printf -- "$@"
	fi
}
print_centered() { # text character
	padding_size=$((80 - 2 - ${#1}))
	printf -- "$2%.0s" $(seq 1 $((padding_size / 2)))
	printf -- ' %s ' "$1"
	printf -- "$2%.0s" $(seq 1 $((padding_size - (padding_size / 2))))
}

check_system() {
	if echo 'test' >'file with "\" in name'
	then
		rm 'file with "\" in name'
		limited_file_system=n
	else
		limited_file_system=y
	fi 2>/dev/null
	export limited_file_system
}

delete_test_remote() {
	rm -rf 'remote-for-tests'
}
create_test_remote() {
	delete_test_remote
	mkdir 'remote-for-tests'
	(
		cd 'remote-for-tests'
		git init --quiet .
		git config --local user.email 'test@localhost'
		git config --local user.name 'test'
		git commit --quiet --allow-empty --message='some commit'
		git branch --move 'my-branch'
	)
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
	| sed -E 's;^\./(.*)\.sh$;\1;' \
	| grep -E "$1" \
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

do_run_test() { # test_name
	exec 3>&4
	{
		{
			export WAS_IT_CALLED_FROM_RUN_SH='indeed'
			if ! cd "$(get_test_dir "$1")"
			then
				printf '0' 1>&4
			elif [ "$debug_mode" = n ]
			then
				if sh "../$(basename "$(get_test_script "$1")")" 1>/dev/null 2>&1
				then
					printf y 1>&4
				else
					printf n 1>&4
				fi
			else
				{
					if sh "../$(basename "$(get_test_script "$1")")"
					then
						printf y 1>&4
					else
						printf n 1>&4
					fi 6>&2 2>&1 1>&6 6>&- \
					| if [ "$use_color" = y ]
					then
						$sed_call -E 's/^.*$/\t'"$esc_char"'[31m&'"$esc_char"'[39m/'
					else
						$sed_call -E 's/^/\t/'
					fi
				} 6>&2 2>&1 1>&6 6>&- | $sed_call -E 's/^/\t/'
			fi 6>&4 4>&1 1>&6 6>&-
		} 6>&3 3>&1 1>&6 6>&- \
		| $sed_call -E 's/^/\tFailed assertion: /'
	} 6>&3 3>&1 1>&6 6>&- 2>&4
	exec 3>&-
}

get_test_result_color() { # test_passed test_result_is_correct
	if [ "$test_result_is_correct" = n ]
	then
		printf '31'
	elif [ "$test_passed" = y ]
	then
		printf '32'
	else
		printf '33'
	fi
}

get_result_status() { # test_passed test_result_is_correct
	if [ "$test_passed" = y ]
	then
		if [ "$test_result_is_correct" = y ]
		then
			printf 'PASSED'
		else
			printf 'UNEXPECTEDLY PASSED'
		fi
	else
		if [ "$test_result_is_correct" = y ]
		then
			printf 'EXPECTEDLY FAILED'
		else
			printf 'FAILED'
		fi
	fi
}

print_test_result() {
	test_result_color="$(get_test_result_color "$test_passed" "$test_result_is_correct")"
	if [ "$test_result_is_correct" = n ] || [ "$verbose_mode" = y ]
	then
		if [ "$use_color" = y ]
		then
			failed_assertion_color="$(test "$test_result_is_correct" = y && printf '33' || printf '31')"
			sed -E 's/^\t(Failed assertion:)(.*)$/\t'"$esc_char"'[1;'"$failed_assertion_color"'m\1'"$esc_char"'[22m\2'"$esc_char"'[39m/'
		else
			cat
		fi <"$output_file" \
		| while IFS= read -r line
		do
			if printf '%s' "$line" | grep -qE '^\t'
			then
				printf '%s\n' "$line" 1>&2
			else
				printf '%s\n' "$line"
			fi
		done
		if [ -n "$known_failure_reason" ]
		then
			printf_color_code '\033[0;1;%im' "$test_result_color" 1>&2
			printf '%s\n' "$known_failure_reason" | cut -c2- \
			| if [ "$use_color" = y ]
			then
				sed -E 's/^.*$/\tKnown failure:'"$esc_char"'[22m &'"$esc_char"'[1m/'
			else
				sed -E 's/^/\tKnown failure: /'
			fi 1>&2
			printf_color_code '\033[22;39m' 1>&2
		fi
	fi
	printf_color_code '\033[0;1;%im' "$test_result_color"
	if [ -z "$parameters_string" ]
	then
		printf '%s - %s' "$(get_result_status "$test_passed" "$test_result_is_correct")" "$display_name"
	else
		printf '    %s: (%s)' "$(get_result_status "$test_passed" "$test_result_is_correct")" "$parameters_string"
	fi
	if [ "$test_passed" = n ]
	then
		current_section="$(printf '%s\n' "$test_result" | grep -E '^-' | tail -n1 | cut -c2-)"
		if [ -n "$current_section" ]
		then
			printf ' ('
			printf_color_code '\033[22m'
			printf '%s' "$current_section"
			printf_color_code '\033[1m'
			printf ')'
		fi
	fi
	printf_color_code '\033[22;39m'
	if [ "$test_passed" = n ] && [ -z "$known_failure_reason" ]
	then
		printf ' (the result is kept)'
	fi
	printf '\n'
}

run_test() ( # test_name
	test_count=0
	failed_count=0
	error_count=0
	PARAMETERS_FILE="$(mktemp)"
	export PARAMETERS_FILE
	output_file="$(mktemp)"
	parametrized_run_cap=2048
	iteration_cap=$((parametrized_run_cap * 8))
	for i in $(seq 1 $iteration_cap)
	do
		sed -iE '/^--------$/ d' "$PARAMETERS_FILE"
		printf -- '--------\n' >>"$PARAMETERS_FILE"
		ROTATE_PARAMETER=y
		export ROTATE_PARAMETER
		cleanup_test "$1"
		create_test_dir "$1" 1>/dev/null
		exec 4>"$output_file"
		test_result="$(
			do_run_test "$1"
		)"
		exec 4>&-
		if ! printf '%s\n' "$test_result" | grep -qE '^\?'
		then
			test_count=$((test_count + 1))
			if [ "$raw_name" = n ]
			then
				display_name="\"$(printf '%s' "$1" | tr '_' ' ')\""
			else
				display_name="$(dirname "$0")/$1.sh"
			fi
			if [ -z "$(sed -En '/^--------$/,$ p' "$PARAMETERS_FILE" | tail -n+2)" ]
			then
				parameters_string=''
			else
				parameters_string="$(sed -En '/^--------$/,$ p' "$PARAMETERS_FILE" | tail -n+2 | sed '/^_/ d' | awk '{if (NF == 4) {print $4} else {print $2}}' | sed -E 's/$/, /' | head -c-3 | tr -d '\n')"
			fi
			test_passed="$(printf '%s\n' "$test_result" | grep -Ev '^[-+]')"
			if [ "$test_passed" = n ]
			then
				failed_count=$((failed_count + 1))
			fi
			known_failure_reason="$(printf '%s' "$test_result" | grep -E '^\+')"
			if { [ -z "$known_failure_reason" ] && [ "$test_passed" = y ] ; } || { [ -n "$known_failure_reason" ] && [ "$test_passed" = n ] ; }
			then
				test_result_is_correct=y
			else
				test_result_is_correct=n
			fi
			if [ "$test_result_is_correct" = n ]
			then
				error_count=$((error_count + 1))
			fi
			if { [ -z "$parameters_string" ] || [ "$test_result_is_correct" = n ] || [ "$verbose_mode" = y ] ; } && { [ "$test_result_is_correct" = n ] || [ "$quiet_level" -eq 0 ] || { [ "$test_passed" = n ] && [ "$quiet_level" -eq 1 ] ; } ; }
			then
				print_test_result
			fi
			if [ "$test_passed" = y ] || [ -n "$known_failure_reason" ]
			then
				cleanup_test "$1"
			fi
			if [ -n "$parameters_string" ]
			then
				test_dir="$(get_test_dir "$1")"
				parametrized_test_dir="${test_dir}__$(awk 'x{print $2} /^--------$/{x=1}' "$PARAMETERS_FILE" | head -c-1 | tr '\n' '_')"
				rm -rf "$parametrized_test_dir"
				if [ -e "$test_dir" ]
				then
					mv "$test_dir" "$parametrized_test_dir"
					mkdir "$test_dir"
				fi
			fi
		else
			cleanup_test "$1"
		fi
		if { [ "$meticulousness" -le 1 ] && [ $test_count -ne 0 ] ; } || [ -z "$(awk '$2 != $3 { print 1 }' "$PARAMETERS_FILE")" ]
		then
			i=x
			break
		fi
		if [ $test_count -eq $parametrized_run_cap ]
		then
			failed_count=$((failed_count + 1))
			error_count=$((error_count + 1))
			printf_color_code '\033[0;1;31m'
			printf '    TOO MANY PARAMETRIZED RUNS (The cap is %i.)' "$parametrized_run_cap"
			printf_color_code '\033[22;39m'
			printf '\n'
			i=x
			break
		fi
	done
	if [ "$i" != x ]
	then
		failed_count=$((failed_count + 1))
		error_count=$((error_count + 1))
		printf_color_code '\033[0;1;31m'
		printf '    TOO MANY ITERATIONS (The cap is %i.)' "$iteration_cap"
		printf_color_code '\033[22;39m'
		printf '\n'
	fi
	rm -f "$output_file"
	if { [ "$meticulousness" -le 1 ] && [ -n "$(sed -En '/^--------$/,$ p' "$PARAMETERS_FILE" | tail -n+2)" ] ; } || { [ $test_count -ge 2 ] && { [ "$error_count" -ne 0 ] || [ "$quiet_level" -eq 0 ] || { [ "$failed_count" -ne 0 ] && [ "$quiet_level" -eq 1 ] ; } ; } ; }
	then
		test_passed="$(test "$failed_count" -eq 0 && printf 'y' || printf 'n')"
		test_result_is_correct="$(test "$error_count" -eq 0 && printf 'y' || printf 'n')"
		printf_color_code '\033[0;1;%im' "$(get_test_result_color "$test_passed" "$test_result_is_correct")"
		printf '%s - %s (%i/%i)' "$(get_result_status "$test_passed" "$test_result_is_correct")" "$display_name" $((test_count - error_count)) $test_count
		printf_color_code '\033[22;39m'
		printf '\n'
	fi
	rm -f "$PARAMETERS_FILE"
	if [ $test_count -eq 0 ]
	then
		return 123
	else
		test "$error_count" -eq 0
	fi
)
update_current_category() { # test_name
	current_category="$(dirname "$1")"
	if [ "$current_category" != "$previous_category" ]
	then
		previous_category="$current_category"
		{
			printf_color_code '\033[1m'
			print_centered "$current_category" '-'
			printf_color_code '\033[22m'
			printf '\n'
		} 1>&5
		printf '%s - passed\n%s - failed\n' "$current_category" "$current_category"
	fi
}
run_tests() {
	if [ -z "$tests" ]
	then
		return 0
	fi
	if printf '' | sed --unbuffered -E 's/^/x/' 1>/dev/null 2>&1
	then
		sed_call='sed --unbuffered'
	else
		sed_call='sed'
	fi
	esc_char="$(printf '\033')"
	exec 5>&1
	test_results="$(
		previous_category=''
		printf '%s\n' "$tests" \
		| if [ "$jobs_num" -eq 1 ]
		then
			while read -r test_name
			do
				update_current_category "$test_name"
				if run_test "$test_name" 1>&5
				then
					printf '%s - passed\n' "$current_category"
				elif [ $? != '123' ]
				then
					printf '%s - failed\n' "$current_category"
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
					{ run_test "$test_name" && printf '0\n' || printf '%i\n' $? ; } 1>"$result_file" 2>&1 &
					running_tests_count=$((running_tests_count + 1))
					running_tests_data="$(printf '%s\n%i %s %s' "$running_tests_data" $! "$result_file" "$test_name" | sed -E '/^\s*$/ d')"
				done
				update_current_category "$(printf '%s\n' "$running_tests_data" | head -n1 | cut -d' ' -f3-)"
				wait "$(printf '%s\n' "$running_tests_data" | head -n 1 | cut -d' ' -f1)"
				result_file="$(printf '%s\n' "$running_tests_data" | head -n 1 | cut -d' ' -f2)"
				head -n-1 "$result_file" \
				| while IFS= read -r line
				do
					if printf '%s' "$line" | grep -qE '^\t'
					then
						printf '%s\n' "$line" 1>&2
					else
						printf '%s\n' "$line" 1>&5
					fi
				done
				if [ "$(tail -n1 "$result_file")" = '0' ]
				then
					printf '%s - passed\n' "$current_category"
				elif [ "$(tail -n1 "$result_file")" != '123' ]
				then
					printf '%s - failed\n' "$current_category"
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
		| sort | uniq -c | awk '{print $1 - 1}'
	)"
	exec 5>&-
}

print_summary() {
	printf_color_code '\033[1m'
	print_centered 'Results' '='
	printf_color_code '\033[22m'
	printf '\n'
	if [ -n "$tests" ]
	then
		i=0
		printf '%s\n' "$tests" | xargs -rn1 -- dirname | uniq -c | awk '{$1=$1;print}' \
		| while read -r category
		do
			i=$((i + 1))
			failed_in_category="$(printf '%s' "$test_results" | head -n $i | tail -n 1)"
			i=$((i + 1))
			passed_in_category="$(printf '%s' "$test_results" | head -n $i | tail -n 1)"
			total_in_category=$((failed_in_category + passed_in_category))
			printf '%s: ' "$(printf '%s' "$category" | cut -d' ' -f2)"
			if [ "$failed_in_category" -eq 0 ]
			then
				printf_color_code '\033[1;32;4m'
				if [ "$total_in_category" -eq 1 ]
				then
					printf 'Passed the test.'
				else
					printf 'Passed all %i tests.' "$total_in_category"
				fi
			else
				printf_color_code '\033[1;31;4m'
				if [ "$total_in_category" -eq 1 ]
				then
					printf 'Failed the test.'
				else
					printf 'Passed %i out of %i tests.' "$passed_in_category" "$total_in_category"
				fi
			fi
			printf_color_code '\033[0m'
			printf '\n'
		done
	fi
	if [ -z "$tests" ]
	then
		passed_tests=0
		total_tests=0
	else
		passed_tests=$(($(printf '%s\n' "$test_results" | sed -n 'n;p' | tr '\n' '+' | head -c-1)))
		total_tests=$(($(printf '%s' "$test_results" | tr '\n' '+')))
	fi
	if [ "$total_tests" -ne 0 ]
	then
		if [ "$passed_tests" -eq "$total_tests" ]
		then
			printf_color_code '\033[42;1;37;4m'
			if [ "$total_tests" -eq 1 ]
			then
				printf 'Passed the test.'
			else
				printf 'Passed all %i tests.' "$total_tests"
			fi
		else
			printf_color_code '\033[41;30;4m'
			if [ "$total_tests" -eq 1 ]
			then
				printf 'Failed the test.'
			else
				printf 'Passed %i out of %i tests.' "$passed_tests" "$total_tests"
			fi
		fi
	else
		printf_color_code '\033[43;1;33;4m'
		printf 'No matching tests were found!'
	fi
	printf_color_code '\033[0m'
	printf '\n'
}

getopt_short_options='c:dfhj:l:m:pqQrv'
getopt_long_options='color:,debug,failed,file-name,help,jobs:,limit:,meticulousness:,print-paths,quiet,quieter,raw,raw-name,verbose,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
only_failed=n
debug_mode=n
quiet_level=0
verbose_mode=n
use_color='auto'
raw_name=n
test_limit=0
print_paths=n
jobs_num=1
max_meticulousness=5
meticulousness=3
while true
do
	case "$1" in
	-c|--color)
		shift
		if printf '%s' "$1" | grep -ixqE 'auto|default'
		then
			use_color='auto'
		elif printf '%s' "$1" | grep -ixqE 'y|yes|always|true|1'
		then
			use_color=y
		elif printf '%s' "$1" | grep -ixqE 'n|no|never|false|0'
		then
			use_color=n
		else
			printf '"%s" is not a valid color setting. (always / never / auto)\n' "$1" 1>&2
			exit 1
		fi
		;;
	-d|--debug)
		debug_mode=y
		;;
	-f|--failed)
		only_failed=y
		;;
	-h|--help)
		print_help
		exit 0
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
	-m|--meticulousness)
		shift
		if [ "$1" -eq "$1" ] 2>/dev/null && [ "$1" -ge 0 ] && [ "$1" -le $max_meticulousness ]
		then
			meticulousness="$1"
		else
			printf '"%s" is not a valid value for meticulousness (0..%i).\n' "$1" $max_meticulousness 1>&2
			exit 1
		fi
		;;
	-p|--print-paths)
		print_paths=y
		;;
	-q|--quiet)
		if [ "$quiet_level" -eq 2 ]
		then
			printf 'Options "--quiet" and "--quiter" are incompatible.\n' 1>&2
			exit 1
		fi
		quiet_level=1
		;;
	-Q|--quieter)
		if [ "$quiet_level" -eq 1 ]
		then
			printf 'Options "--quiet" and "--quiter" are incompatible.\n' 1>&2
			exit 1
		fi
		quiet_level=2
		;;
	-r|--raw|--raw-name|--file-name)
		raw_name=y
		;;
	-v|--verbose)
		verbose_mode=y
		;;
	--version)
		print_version
		exit 0
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
if [ "$quiet_level" -ne 0 ] && [ "$verbose_mode" = y ]
then
	printf 'Options "--quiet" and "--verbose" are incompatible.\n' 1>&2
	exit 1
fi
export meticulousness

normalize_filter_entry() { # filter_entry
	if [ -f "$1" ]
	then
		printf '%s' "$1" \
		| sed -E -e 's;^.*/([^/]+/[^/]+)$;\1;' \
			-e 's;^[^/]+$;./&;' \
			-e "s;^\\./;$(basename "$(pwd)")/;" \
			-e 's/\.sh$//' \
			-e 's/^/^/' -e 's/$/$/'
	else
		printf '%s' "$1"
	fi
}
if [ $# -eq 0 ]
then
	filter=''
else
	filter="($(normalize_filter_entry "$1"))"
	shift
	while [ $# -ne 0 ]
	do
		filter="$filter|($(normalize_filter_entry "$1"))"
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

check_system

cd '../bin'
PATH="$(pwd):$PATH"
cd "$OLDPWD"
export PATH
create_test_remote
run_tests
print_summary
if [ "$passed_tests" -eq "$total_tests" ]
then
	delete_test_remote
fi
[ "$total_tests" -ne 0 ] && [ "$passed_tests" -eq "$total_tests" ]
