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
	printf '    -C, --check\t\t- Only check if all tests pass. (Equivalent to "-sSQ".)\n'
	printf '    -d, --debug\t\t- Print outputs of all commands in run in the tests.\n'
	printf '    -f, --failed\t- Rerun only the tests that failed the last time when\n\t\t\t  they were run. (Check the presence of the test dir.)\n'
	printf '    -j, --jobs=N\t- Run N tests in parallel. (default is sequentially)\n\t\t\t  N=0 uses all available processing units. ("nproc")\n'
	printf '    -l, --limit=number\t- Set maximum number of tests to be run. (It pairs well\n\t\t\t  with "--failed" to e.g. rerun the first failed test.)\n'
	printf '    -m, --meticulous=N\t- Set how many tests will be run. Allowed values are\n\t\t\t  0..5 (default=3). (See the section "Meticulousness".)\n'
	printf '    -p, --print-paths\t- Instead of running tests, print their paths and exit.\n\t\t\t  (The paths are relative to the directory "tests".)\n'
	printf '\t--progress\t- Show progress information during testing. (It uses the\n\t\t\t  multi-threaded code, which adds some overhead for\n\t\t\t  a single job run.)\n\t\t\t  This is the default when color is enabled, the quiet\n\t\t\t  mode is disabled and there are multiple jobs.\n'
	printf '\t--no-progress\t- Don'\''t show progress information. (See "--progress".)\n\t\t\t  This is useful to avoid outputting ANSI escape codes.\n'
	printf '    -q, --quiet\t\t- Don'\''t print summaries for passed tests.\n'
	printf '    -Q, --quieter\t- Don'\''t print summaries for known failures either.\n'
	printf '    -r, --raw-name\t- Print paths to test files instead of prettified names.\n'
	printf '    -s, --skip-at-fail\t- Don'\''t test other sets of parameters for a test when\n\t\t\t  one already failed. (Other tests still run.)\n'
	printf '    -S, --stop-at-fail\t- Don'\''t start other tests after one has failed; exit as\n\t\t\t  soon as all currently running ones has finished.\n'
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
	printf '    5 - All combinations of parameters are run in parametric tests but non\n\tstandard versions of options are tested (e.g. "--mess" instead of\n\t"--message"). (Sometimes it can catch a weird option naming conflict but\n\tgenerarly running it has sense only for big merges and releases.)\n'
}

print_version() {
	printf 'test script version 2.2.0\n'
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
get_test_dir() { # test_name [parameters_string]
	printf '%s/t_dir__%s/%s' "$(basename "$(dirname "$1")")" "$(basename "$1")" "$2"
}

cleanup_test() { # test_name [parameters_string]
	rm -rf "$(get_test_dir "$@")"
}
create_test_dir() { # test_name [parameters_string]
	test_dir="$(get_test_dir "$1")"
	mkdir -p "$test_dir"
	test_dir="$(get_test_dir "$1" "$2")"
	mkdir "$test_dir"
}

find_tests() { # pattern
	./list.sh \
	| sed -E 's/\.sh$//' \
	| grep -E "$1" \
	| while read -r test_name
	do
		if [ "$only_failed" = n ] || [ -d "$(get_test_dir "$test_name")" ]
		then
			printf '%s\n' "$test_name"
		fi
	done \
	| if [ "$test_limit" -eq 0 ]
	then
		cat
	else
		head -n "$test_limit"
	fi
}

get_test_display_name() { # raw_name
	if [ "$raw_name" = n ]
	then
		printf '"'
		printf '%s' "$1" | sed -E -e 's/_/ /g' -e 's;/; -> ;g'
		printf '"'
	else
		printf '%s' "$(dirname "$0")/$1.sh"
	fi
}

format_time() { # seconds
	if [ "$1" -ge 3600 ]
	then
		printf '%ih%02im%02is' $(($1 / 3600)) $(($1 % 3600 / 60)) $(($1 % 60))
	elif [ "$1" -ge 60 ]
	then
		printf '%im%02is' $(($1 % 3600 / 60)) $(($1 % 60))
	else
		printf '%is' $(($1 % 60))
	fi
}

do_run_test() { # test_name
	exec 3>&4
	{
		{
			export WAS_IT_CALLED_FROM_RUN_SH='indeed'
			if ! cleanup_test "$1" 'current' || ! create_test_dir "$1" 'current' || ! cd "$(get_test_dir "$1" 'current')"
			then
				printf '0' 1>&4
			elif [ "$debug_mode" = n ]
			then
				if sh "../../$(basename "$(get_test_script "$1")")" 1>/dev/null 2>&1
				then
					printf y 1>&4
				else
					printf n 1>&4
				fi
			else
				{
					if sh "../../$(basename "$(get_test_script "$1")")"
					then
						printf y 1>&4
					else
						printf n 1>&4
					fi 6>&2 2>&1 1>&6 6>&- \
					| if [ "$use_color" = y ]
					then
						$SED_CALL -E 's/^.*$/\t'"$esc_char"'[31m&'"$esc_char"'[39m/'
					else
						$SED_CALL -E 's/^/\t/'
					fi
				} 6>&2 2>&1 1>&6 6>&- | $SED_CALL -E 's/^/\t/'
			fi 6>&4 4>&1 1>&6 6>&-
		} 6>&3 3>&1 1>&6 6>&- \
		| $SED_CALL -E 's/^/\tFailed assertion: /'
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
	printf '    %s: (%s)' "$(get_result_status "$test_passed" "$test_result_is_correct")" "$parameters_string"
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
	printf_color_code '\033[2m'
	printf ' '
	format_time $((test_run_end_time - test_run_start_time))
	printf_color_code '\033[22m'
	printf '\n'
}

run_test() ( # test_name
	test_start_time="$(date '+%s')"
	test_count=0
	failed_count=0
	error_count=0
	PARAMETERS_FILE="$(mktemp)"
	export PARAMETERS_FILE
	output_file="$(mktemp)"
	parametrized_run_cap=10000
	iteration_cap=$((parametrized_run_cap * 8))
	cleanup_test "$1"
	for i in $(seq 1 $iteration_cap)
	do
		sed -iE '/^--------$/ d' "$PARAMETERS_FILE"
		printf -- '--------\n' >>"$PARAMETERS_FILE"
		ROTATE_PARAMETER=y
		export ROTATE_PARAMETER
		exec 4>"$output_file"
		test_run_start_time="$(date '+%s')"
		test_result="$(
			do_run_test "$1"
		)"
		test_run_end_time="$(date '+%s')"
		exec 4>&-
		if ! printf '%s\n' "$test_result" | grep -qE '^\?'
		then
			test_count=$((test_count + 1))
			display_name="$(get_test_display_name "$1")"
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
			if { [ "$test_result_is_correct" = n ] || [ "$verbose_mode" = y ] ; } \
				&& { [ "$test_result_is_correct" = n ] || [ "$quiet_level" -eq 0 ] || { [ "$test_passed" = n ] && [ "$quiet_level" -eq 1 ] ; } ; }
			then
				print_test_result
			fi
			if [ "$test_result_is_correct" = n ]
			then
				error_count=$((error_count + 1))
				if [ -n "$parameters_string" ]
				then
					test_dir="$(get_test_dir "$1" 'current')"
					if [ -e "$test_dir" ]
					then
						parameters_string="$(awk 'x{print $2} /^--------$/{x=1}' "$PARAMETERS_FILE" | head -c-1 | tr '\n' '_')"
						parametrized_test_dir="$(get_test_dir "$1" "$parameters_string")"
						mv "$test_dir" "$parametrized_test_dir"
					fi
				fi
				if [ "$skip_on_fail" = y ]
				then
					i=x
					break
				fi
			else
				cleanup_test "$1" 'current'
			fi
		else
			cleanup_test "$1" 'current'
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
	rmdir "$(get_test_dir "$1")" 2>/dev/null || true
	test_end_time="$(date '+%s')"
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
	if [ "$test_count" -ne 0 ] && { [ "$error_count" -ne 0 ] || [ "$quiet_level" -eq 0 ] || { [ "$failed_count" -ne 0 ] && [ "$quiet_level" -eq 1 ] ; } ; }
	then
		test_passed="$(test "$failed_count" -eq 0 && printf 'y' || printf 'n')"
		test_result_is_correct="$(test "$error_count" -eq 0 && printf 'y' || printf 'n')"
		printf_color_code '\033[0;1;%im' "$(get_test_result_color "$test_passed" "$test_result_is_correct")"
		printf '%s - %s (%i/%i)' "$(get_result_status "$test_passed" "$test_result_is_correct")" "$display_name" $((test_count - error_count)) $test_count
		printf_color_code '\033[22;2;39m'
		printf ' '
		format_time $((test_end_time - test_start_time))
		printf_color_code '\033[22m'
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
	if [ -n "$1" ]
	then
		current_category="$(dirname "$1")"
	else
		current_category=''
	fi
	if [ "$current_category" != "$previous_category" ]
	then
		if [ -n "$previous_category" ]
		then
			category_end_time="$(date '+%s')"
			printf '%s - time = %i\n' "$previous_category" $((category_end_time - category_start_time + 1))
			category_start_time="$category_end_time"
		fi
		previous_category="$current_category"
		if [ -n "$current_category" ]
		then
			{
				printf_color_code '\033[1m'
				print_centered "$current_category" '-'
				printf_color_code '\033[22m'
				printf '\n'
			} 1>&5
			printf '%s - passed\n%s - failed\n' "$current_category" "$current_category"
		fi
	fi
}
print_progress() { # total_count running_count finalizing_count done_count alive_children_pids
	printf '(Remaining tests: Waiting - %i, Running - %i' "$(($1 - $2 - $3 - $4))" "$2"
	printf_color_code '\033[2m'
	printf ' (%s)' "$(printf '%s' "$5" | tr '\n' ',' | sed -E -e 's/^([0-9]+,).*$/\1.../' -e 's/,/, /g')"
	printf_color_code '\033[22m'
	printf ', Finalizing - %i)\n' "$3"
	done_bar_lenght=$(($4 * 78 / $1))
	done_bar_lenght=$((done_bar_lenght + (done_bar_lenght == 0 && $4 != 0)))
	finalizing_bar_lenght=$(($3 * 78 / $1))
	finalizing_bar_lenght=$((finalizing_bar_lenght + (finalizing_bar_lenght == 0 && $3 != 0)))
	running_bar_lenght=$(($2 * 78 / $1))
	running_bar_lenght=$((running_bar_lenght + (running_bar_lenght == 0 && $2 != 0)))
	remaining_bar_lenght=$((($1 - $2 - $3 - $4) * 78 / $1))
	missing_bar_lenght=$((78 - (done_bar_lenght + finalizing_bar_lenght + running_bar_lenght + remaining_bar_lenght)))
	if [ $missing_bar_lenght -gt 0 ]
	then
		# We try to keep the "done" part of progress bar stable, so we dump the missing length to the later segments.
		if [ $remaining_bar_lenght -ne 0 ]
		then
			remaining_bar_lenght=$((remaining_bar_lenght + missing_bar_lenght))
		else
			running_bar_lenght=$((running_bar_lenght + missing_bar_lenght))
		fi
	elif [ $missing_bar_lenght -lt 0 ]
	then
		# The "missing_bar_lenght" will never be smaller than -3.
		# We try to distribute the cuts more or less even, preferring the parts showing the work that currently runs (to not overestimate the progress).
		# We try not to touch the "done" part if not necessary, so the bar doesn't appear to go backwards.
		for i in 1 2 3
		do
			if [ $running_bar_lenght -ge 2 ]
			then
				running_bar_lenght=$((running_bar_lenght - 1))
				missing_bar_lenght=$((missing_bar_lenght + 1))
				if [ $missing_bar_lenght -eq 0 ]
				then
					break
				fi
			fi
			if [ $finalizing_bar_lenght -ge 2 ]
			then
				finalizing_bar_lenght=$((finalizing_bar_lenght - 1))
				missing_bar_lenght=$((missing_bar_lenght + 1))
				if [ $missing_bar_lenght -eq 0 ]
				then
					break
				fi
			fi
			if [ $remaining_bar_lenght -ge 2 ]
			then
				remaining_bar_lenght=$((remaining_bar_lenght - 1))
				missing_bar_lenght=$((missing_bar_lenght + 1))
				if [ $missing_bar_lenght -eq 0 ]
				then
					break
				fi
			fi
		done
		done_bar_lenght=$((done_bar_lenght + missing_bar_lenght))
	fi
	printf '['
	if [ $done_bar_lenght -ne 0 ]
	then
		printf '#%.0s' $(seq 1 $done_bar_lenght)
	fi
	if [ $finalizing_bar_lenght -ne 0 ]
	then
		printf '+%.0s' $(seq 1 $finalizing_bar_lenght)
	fi
	if [ $running_bar_lenght -ne 0 ]
	then
		printf -- '-%.0s' $(seq 1 $running_bar_lenght)
	fi
	if [ $remaining_bar_lenght -ne 0 ]
	then
		printf_color_code '\033[2m'
		printf '.%.0s' $(seq 1 $remaining_bar_lenght)
		printf_color_code '\033[22m'
	fi
	printf ']\n'
}
run_tests() {
	if [ -z "$tests" ]
	then
		return 0
	fi
	if printf '' | sed --unbuffered -E 's/^/x/' 1>/dev/null 2>&1
	then
		SED_CALL='sed --unbuffered'
	else
		SED_CALL='sed'
	fi
	esc_char="$(printf '\033')"
	exec 5>&1
	test_results="$(
		previous_category=''
		category_start_time="$(date '+%s')"
		total_test_count="$(printf '%s\n' "$tests" | wc -l)"
		printf '%s\n' "$tests" \
		| if [ "$jobs_num" -eq 1 ] && [ "$show_progress" = n ]
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
					if [ "$stop_on_error" = y ]
					then
						break
					fi
				fi
			done
			update_current_category ''
		else
			any_test_has_failed=n
			running_tests_count=0
			running_tests_data=''
			alive_children=''
			finalizing_tests_count=0
			done_tests_count=0
			output_buffer_file="$(mktemp)"
			while true
			do
				while [ $running_tests_count -ne "$jobs_num" ] && { [ "$stop_on_error" = n ] || [ "$any_test_has_failed" = n ] ; }
				do
					if ! read -r test_name
					then
						break
					fi
					result_file="$(mktemp)"
					{ run_test "$test_name" && printf '0\n' || printf '%i\n' $? ; } 1>"$result_file" 2>&1 &
					running_tests_count=$((running_tests_count + 1))
					running_tests_data="$(printf '%s\n%i %s %s %s' "$running_tests_data" $! "$result_file" "$test_name" "$(date '+%s')" | grep -vE '^$')"
					alive_children="$(printf '%s\n%i' "$alive_children" $! | grep -vE '^$')"
				done
				if [ $running_tests_count -eq 0 ]
				then
					break
				fi
				update_current_category "$(printf '%s\n' "$running_tests_data" | head -n1 | cut -d' ' -f3)" 5>>"$output_buffer_file"
				test_display_name="$(get_test_display_name "$(printf '%s\n' "$running_tests_data" | head -n 1 | cut -d' ' -f3)")"
				if [ "$show_progress" = y ]
				then
					printf 'PENDNG - %s (?/?) \n' "$test_display_name"
					print_progress "$total_test_count" "$running_tests_count" "$finalizing_tests_count" "$done_tests_count" "$alive_children"
				fi 1>>"$output_buffer_file"
				pending_test_start_time="$(printf '%s\n' "$running_tests_data" | head -n 1 | cut -d' ' -f4)"
				while true
				do
					if [ "$show_progress" = y ]
					then
						printf '\033[3A\033[%iC' $((${#test_display_name} + 16))
						printf_color_code '\033[2m'
						format_time $(($(date '+%s') - pending_test_start_time))
						printf_color_code '\033[22m'
						printf '\033[3E'
					fi 1>>"$output_buffer_file"
					cat "$output_buffer_file" 1>&5
					: >"$output_buffer_file"
					new_dead_children="$(
						printf '%s\n' "$alive_children" \
						| while read -r pid
						do
							if ! kill -0 "$pid" 2>/dev/null
							then
								printf '%i\n' "$pid"
							fi
						done
					)"
					if [ -z "$new_dead_children" ]
					then
						sleep 1
					else
						dead_children="$(printf '%s\n%s' "$dead_children" "$new_dead_children" | grep -vE '^$')"
						new_dead_children_count="$(printf '%s\n' "$new_dead_children" | wc -l)"
						running_tests_count=$((running_tests_count - new_dead_children_count))
						finalizing_tests_count=$((finalizing_tests_count + new_dead_children_count))
						alive_children="$(printf '%s' "$alive_children" | grep -vEx "$(printf '%s' "$new_dead_children" | sed -E 's/^.*$/(^&$)/' | tr '\n' '|')" || true)"
						break
					fi
				done
				if [ "$show_progress" = y ]
				then
					printf '\033[3A\033[0J'
				fi 1>>"$output_buffer_file"
				while printf '%s' "$dead_children" | grep -qEx "$(printf '%s\n' "$running_tests_data" | head -n 1 | cut -d' ' -f1)"
				do
					result_file="$(printf '%s\n' "$running_tests_data" | head -n 1 | cut -d' ' -f2)"
					head -n-1 "$result_file" \
					| while IFS= read -r line
					do
						if printf '%s' "$line" | grep -qE '^\t'
						then
							cat "$output_buffer_file" 1>&5
							: >"$output_buffer_file"
							printf '%s\n' "$line" 1>&2
						else
							printf '%s\n' "$line" 1>>"$output_buffer_file"
						fi
					done
					if [ "$(tail -n1 "$result_file")" = '0' ]
					then
						printf '%s - passed\n' "$current_category"
					elif [ "$(tail -n1 "$result_file")" != '123' ]
					then
						printf '%s - failed\n' "$current_category"
						any_test_has_failed=y
					fi
					dead_children="$(printf '%s' "$dead_children" | grep -vFx "$(printf '%s\n' "$running_tests_data" | head -n 1 | cut -d' ' -f1)" || true)"
					finalizing_tests_count=$((finalizing_tests_count - 1))
					done_tests_count=$((done_tests_count + 1))
					rm -f "$result_file"
					running_tests_data="$(printf '%s\n' "$running_tests_data" | tail -n+2)"
					if [ -n "$running_tests_data" ]
					then
						update_current_category "$(printf '%s\n' "$running_tests_data" | head -n1 | cut -d' ' -f3)" 5>>"$output_buffer_file"
					fi
				done
			done
			update_current_category '' 5>>"$output_buffer_file"
			cat "$output_buffer_file" 1>&5
			rm -f "$output_buffer_file"
		fi \
		| sort | uniq -c | sed -E 's/^.* - time = ([0-9]+)$/\1/' | awk '{print $1 - 1}'
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
			i=$((i + 1))
			category_time="$(printf '%s' "$test_results" | head -n $i | tail -n 1)"
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
			printf_color_code '\033[22;2;39;24m'
			printf ' '
			if [ "$jobs_num" -ne 1 ]
			then
				printf '~'
			fi
			format_time "$category_time"
			printf_color_code '\033[0m'
			printf '\n'
		done
	fi
	if [ -z "$tests" ]
	then
		passed_tests=0
		total_tests=0
	else
		passed_tests=$(($(printf '%s\n' "$test_results" | sed -n 'n;p;n' | tr '\n' '+')0))
		total_tests=$(($(printf '%s' "$test_results" | sed -n 'p;n;p;n' | tr '\n' '+')0))
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
	printf_color_code '\033[2;39;49;24m'
	printf ' '
	format_time $((total_time_end - total_time_start))
	printf_color_code '\033[0m'
	printf '\n'
}

getopt_short_options='c:Cdfhj:l:m:pqQrsSv'
getopt_long_options='color:,check,debug,failed,file-name,help,jobs:,limit:,meticulousness:,print-paths,progress,no-progress,quiet,quieter,raw,raw-name,skip-at-fail,skip-at-error,skip-on-fail,skip-on-error,stop-at-fail,stop-at-error,stop-on-fail,stop-on-error,verbose,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
only_failed=n
debug_mode=n
quiet_level=0
verbose_mode=n
use_color=auto
show_progress=auto
raw_name=n
skip_on_fail=n
stop_on_error=n
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
	-C|--check)
		shift
		set -- '-C' '--skip-at-fail' '--stop-at-fail' '--quieter' "$@"
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
	--progress)
		show_progress=y
		;;
	--no-progress)
		show_progress=n
		;;
	-q|--quiet)
		if [ "$quiet_level" -eq 2 ]
		then
			printf 'Options "--quiet" and "--quieter" are incompatible.\n' 1>&2
			exit 1
		fi
		quiet_level=1
		;;
	-Q|--quieter)
		if [ "$quiet_level" -eq 1 ]
		then
			printf 'Options "--quiet" and "--quieter" are incompatible.\n' 1>&2
			exit 1
		fi
		quiet_level=2
		;;
	-r|--raw|--raw-name|--file-name)
		raw_name=y
		;;
	-s|--skip-at-fail|--skip-at-error|--skip-on-fail|--skip-on-error)
		skip_on_fail=y
		;;
	-S|--stop-at-fail|--stop-at-error|--stop-on-fail|--stop-on-error)
		stop_on_error=y
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
if [ "$show_progress" = auto ]
then
	if [ "$use_color" = y ] && [ "$jobs_num" -gt 1 ] && [ "$quiet_level" -eq 0 ]
	then
		show_progress=y
	else
		show_progress=n
	fi
fi
if [ "$quiet_level" -ne 0 ] && [ "$verbose_mode" = y ]
then
	case "$quiet_level" in
		1) printf 'Options "--quiet" and "--verbose" are incompatible.\n' 1>&2 ;;
		2) printf 'Options "--quieter" and "--verbose" are incompatible.\n' 1>&2 ;;
	esac
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

trap 'trap - INT ; kill -s KILL -- -$$' INT

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
total_time_start="$(date '+%s')"
run_tests
total_time_end="$(date '+%s')"
print_summary
if [ "$passed_tests" -eq "$total_tests" ]
then
	delete_test_remote
fi
[ "$total_tests" -ne 0 ] && [ "$passed_tests" -eq "$total_tests" ]
