#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/facets.sh"

print_help() {
	printf '%s - Script that runs "run.sh" first with all tests and then reruns it\nfor all failed test every time any relevant file changes.\n' "$(basename "$0")"
	printf 'It exits when there are no failed tests.\n'
	printf '\n'
	printf 'Usage: %s [<options>] [--] [<filter>...]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -a, --altered\t- Run only the tests changed since the last commit.\n\t\t\t  (Only changes in individual test files count, not in\n\t\t\t  the common test utilities that affect every test.)\n\t\t\t  Renamed tests with 100%% similarity are omitted.\n\t\t\t  (See also "--since".)\n'
	printf '    -A, --since=X\t- Selects the commit used as reference by "--altered".\n\t\t\t  (It implies "--altered".)\n\t\t\t  Special cases:\n\t\t\t  * Empty / blank string means INDEX.\n\t\t\t  * Strings starting with "~" or "^" imply HEAD.\n\t\t\t    (So "~2" means the same as "HEAD~2".)\n\t\t\t  * "-" means all changes since branching from "master".\n'
	printf '    -h, --help\t\t- Print this help message end exit.\n'
	printf '    -c, --color=when\t- Set color mode (always / never / auto).\n'
	printf '    -m, --meticulous=X\t- Set how many tests / test variants will be run.\n\t\t\t  (For more info, run "run.sh --help".)\n'
	printf '    -s, --skip-init\t- Skip the initial run that checks which tests fail.\n\t\t\t  (Assume that the relevant tests has failed already.)\n'
	printf '\t--version\t- Print version information and exit.\n'
	printf '\n'
	printf 'For info about filters, run "run.sh --help".\n'
}

print_version() {
	printf 'test monitoring script version 1.0.0\n'
}

call_run_sh__with_altered() { # [arg...]
	if [ "$only_altered" = n ]
	then
		./run.sh "$@"
	else
		./run.sh --since="$altered_reference" "$@"
	fi
}

call_run_sh__with_settings() { # [arg...]
	if [ -n "$meticulousness" ]
	then
		call_run_sh__with_altered --meticulousness="$meticulousness" "$@"
	else
		call_run_sh__with_altered "$@"
	fi
}

get_all_tests_count() { # [filter]...
	call_run_sh__with_altered --print-paths -- "$@" | wc -l
}

get_failing_tests_count() { # [filter]...
	call_run_sh__with_altered --failed --print-paths -- "$@" | wc -l
}

get_first_failing_test() { # [filter]...
	call_run_sh__with_altered --failed --print-paths -- "$@" 2>/dev/null | head -n 1
}

get_istash_files() {
	find '../lib' '../bin' -type f ! -name '.*.sw?' | sort
}

get_common_test_files() {
	find '.' -maxdepth 1 -type f -name '*.sh' ! -name '.*' | sort
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

initial_run() { # [filter]...
	if [ "$skip_init" = n ]
	then
		call_run_sh__with_settings --skip-at-fail --color="$use_color" --jobs=0 -- "$@"
	else
		false
	fi
}

monitor_tests() { # [filter]...
	if ! initial_run "$@"
	then
		if [ "$(get_all_tests_count "$@")" -eq 0 ]
		then
			return 1
		fi
		if [ "$skip_init" = n ]
		then
			printf '\n\n\n'
		fi
		while ! call_run_sh__with_settings --failed --skip-at-fail --stop-at-fail --verbose --color="$use_color" -- "$@"
		do
			wait_for_change "$@"
			printf '\n\n\n'
		done
	fi
}

getopt_short_options='aA:c:hm:s'
getopt_long_options='altered,since:,color:,help,meticulousness:,skip-init,version'
normalized_options="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$normalized_options"
only_altered=n
altered_reference=HEAD
use_color=auto
meticulousness=''
skip_init=n
while true
do
	case "$1" in
	-a|--altered)
		only_altered=y
		;;
	-A|--since)
		shift
		altered_reference="$1"
		only_altered=y
		;;
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
		printf '%s\n' "$1" \
		| tr '|' '\n' \
		| sed -E '/^(quickie|complete)$/d' \
		| while read -r x
		do
			parse_meticulousness "$x" 1>/dev/null
		done
		meticulousness="$1"
		;;
	-s|--skip-init)
		skip_init=y
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
