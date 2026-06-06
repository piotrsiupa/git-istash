#!/usr/bin/env sh

set -eu

print_help() {
	printf '%s - A test script that runs "shellcheck" on all shell scripts in\n    this repository.\n' "${0##*/}"
	printf '\n'
	printf 'Usage: %s [<options...>]\n' "${0##*/}"
	printf '\n'
	printf 'Options:\n'
	printf '    -a, --altered\t- Check only the tests changed since the last commit.\n\t\t\t  (Only changes in individual test files count, not in\n\t\t\t  the common test utilities that affect every test.)\n\t\t\t  Renamed tests with 100%% similarity are omitted.\n\t\t\t  (See also "--since".)\n'
	printf '    -A, --since=X\t- Selects the commit used as reference by "--altered".\n\t\t\t  (It implies "--altered".)\n\t\t\t  Special cases:\n\t\t\t  * Empty / blank string means INDEX.\n\t\t\t  * Strings starting with "~" or "^" imply HEAD.\n\t\t\t    (So "~2" means the same as "HEAD~2".)\n\t\t\t  * "-" means all changes since branching from "master".\n'
	printf '    -h, --help\t\t- Print this help text and exit.\n'
	printf '    -s, --skip-tests\t- Do not check test scripts from sub-directories of\n\t\t\t  the directory "tests". (a lot faster execution)\n'
	printf '    -V, --version\t- Print version information and exit.\n'
}

print_version() {
	printf 'shellcheck wrapper script version 1.2.2\n'
}

list_files() {
	find bin -type f ! -name '.*' | sort
	find lib -type f ! -name '.*' | sort
	find . -maxdepth 1 -type f -name '*.sh' | cut -c3- | sort
	find tests -maxdepth 1 -type f -name '*.sh' | sort
	if [ "$skip_tests" = n ]
	then
		if [ "$only_altered" = n ]
		then
			tests/list.sh --relative
		else
			tests/list.sh --relative --since="$altered_reference"
		fi
	fi
}

run_shellcheck() {
	test_dirs="$(find tests -mindepth 1 -maxdepth 1 -type d -print0 | xargs -r0n1 basename | sed -E 's;^;tests/;' | tr '\n' ':')"  # Not a clean solution but `shellcheck` doesn't support anything better.
	list_files | xargs -- shellcheck --shell=sh --source-path="${test_dirs}tests:lib/git-istash"
	printf 'All %i files are correct.\n' "$(list_files | wc -l)"
}

getopt_short_options='aA:hsV'
getopt_long_options='altered,since:,help,skip-tests,version'
normalized_options="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"${0##*/}" -ssh -- "$@")"
eval set -- "$normalized_options"
only_altered=n
altered_reference=HEAD
skip_tests=n
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
	-h|--help)
		print_help
		exit 0
		;;
	-s|--skip-tests)
		skip_tests=y
		;;
	-V|--version)
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
if [ $# -ne 0 ]
then
	printf 'No argument is allowed.\n' 1>&2
	exit 2
fi
if [ "$only_altered" = y ] && [ "$skip_tests" = y ]
then
	printf 'Options "--altered" and "--skip-tests" are incompatible.\n' 1>&2
	exit 2
fi

cd "$(dirname "$0")/.."
run_shellcheck
