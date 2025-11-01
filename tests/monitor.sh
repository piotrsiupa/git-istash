#!/usr/bin/env sh

set -eu

print_help() {
	printf '%s - Script that runs "run.sh" first with all tests and then reruns it\nfor all failed test every time any relevant file changes.\n' "$(basename "$0")"
	printf 'It exits when there are no failed tests.\n'
	printf '\n'
	printf 'Usage: %s [<options>] [--] [<filter>...]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help message end exit.\n'
	printf '    -c, --color=when\t- Set color mode (always / never / auto).\n'
	printf '    -m, --meticulous=N\t- Set how many tests will be run. Allowed values are\n\t\t\t  0..5 (default=3). (See the section "Meticulousness".)\n'
	printf '\t--version\t- Print version information and exit.\n'
	printf '\n'
	printf 'For info about filters and meticulousness, see "run.sh --help".\n'
}

print_version() {
	printf 'test monitoring script version 1.0.0\n'
}

get_all_tests_count() { # [filter]...
	./run.sh --print-paths -- "$@" | wc -l
}

get_failing_tests_count() { # [filter]...
	./run.sh --failed --print-paths -- "$@" | wc -l
}

get_first_failing_test() { # [filter]...
	./run.sh --failed --print-paths -- "$@" | head -n 1
}

get_istash_files() {
	find '../lib' '../bin' -type f ! -name '.*.sw?' | sort
}

get_common_test_files() {
	find '.' -type f -maxdepth 1 -name '*.sh' ! -name '.*' | sort
}

get_times() { # file_lists...
	printf '%s\n' "$@" | xargs -- stat -c '%Y' -- 2>/dev/null || true
}

wait_for_change() { # [filter]...
	printf '\n\n' 1>&2
	printf 'Failing tests count: %i/%i\n' "$(get_failing_tests_count "$@")" "$(get_all_tests_count "$@")" 1>&2
	first_failing_test="$(get_first_failing_test "$@")"
	printf 'Next to fix: "%s"...' "$first_failing_test" 1>&2
	previous_istash_files="$(get_istash_files)"
	previous_test_files="$(get_common_test_files)"
	previous_times="$(get_times "$first_failing_test" "$previous_test_files" "$previous_istash_files")"
	while true
	do
		sleep 1
		current_istash_files="$(get_istash_files)"
		current_test_files="$(get_common_test_files)"
		if [ "$current_istash_files" != "$previous_istash_files" ] || [ "$current_test_files" != "$previous_test_files" ]
		then
			break
		fi
		if ! current_times="$(get_times "$first_failing_test" "$current_test_files" "$current_istash_files")"
		then
			break
		fi
		if [ "$current_times" != "$previous_times" ]
		then
			break
		fi
	done
	sleep 1
}

monitor_tests() { # [filter]...
	if ! ./run.sh --skip-at-fail --color="$use_color" --meticulousness="$meticulousness" --jobs=0 -- "$@"
	then
		printf '\n\n\n'
		while ! ./run.sh --failed --skip-at-fail --stop-at-fail --verbose --color="$use_color" --meticulousness="$meticulousness" -- "$@"
		do
			wait_for_change "$@"
			printf '\n\n\n'
		done
	fi
}

getopt_short_options='c:hm:'
getopt_long_options='color:,help,meticulousness:,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
use_color=auto
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
			use_color=yes
		elif printf '%s' "$1" | grep -ixqE 'n|no|never|false|0'
		then
			use_color=no
		else
			printf '"%s" is not a valid color setting. (always / never / auto)\n' "$1" 1>&2
			exit 1
		fi
		;;
	-h|--help)
		print_help
		exit 0
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

cd "$(dirname "$0")"
monitor_tests "$@"
