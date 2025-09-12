#!/usr/bin/env sh

set -eu

print_help() {
	printf '%s - A test script that runs "shellcheck" on all shell scripts in\n    this repository.\n' "$(basename "$0")"
	printf '\n'
	printf 'Usage: %s [<options...>]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help message and exit.\n'
	printf '    -s, --skip-tests\t- Do not check test scripts from sub-directories of\n\t\t\t  the directory "tests". (a lot faster execution)\n'
	printf '\t--version\t- Print version information and exit.\n'
}

print_version() {
	printf 'shellcheck wrapper script version 1.1.2\n'
}

list_files() {
	find bin -type f ! -name '.*' | sort
	find lib -type f ! -name '.*' | sort
	find . -maxdepth 1 -type f -name '*.sh' | cut -c3- | sort
	find tests -maxdepth 1 -type f -name '*.sh' | sort
	if [ "$skip_tests" = n ]
	then
		tests/list.sh --relative
	fi
}

run_shellcheck() {
	test_dirs="$(find tests -mindepth 1 -maxdepth 1 -type d -print0 | xargs -r0n1 basename | sed -E 's;^;tests/;' | tr '\n' ':')"  # Not a clean solution but `shellcheck` doesn't support anything better.
	list_files | xargs -- shellcheck --shell=sh --source-path="${test_dirs}tests:lib/git-istash"
	printf 'All %i files are correct.\n' "$(list_files | wc -l)"
}

getopt_short_options='hs'
getopt_long_options='help,skip-tests,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
skip_tests=n
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
		;;
	-s|--skip-tests)
		skip_tests=y
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
if [ $# -ne 0 ]
then
	printf 'No argument is allowed.\n' 1>&2
	exit 1
fi

cd "$(dirname "$0")/.."
run_shellcheck
