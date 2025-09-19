#!/usr/bin/env sh

set -eu

print_help() {
	printf '%s - A script to remove all the tests results.\n' "$(basename "$0")"
	printf '(This has no purpose except visually clearing the directories. '
	printf 'Other scripts can\nwork around existing test results no problem, or even use them.)\n'
	printf '\n'
	printf 'Usage: %s [<options...>]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help message and exit.\n'
	printf '\t--version\t- Print version information and exit.\n'
}

print_version() {
	printf 'shellcheck wrapper script version 1.0.1\n'
}

clear_results() {
	find . -mindepth 2 -maxdepth 2 -type d -name 't_dir__*' -exec rm -rf {} +
}

getopt_short_options='hs'
getopt_long_options='help,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
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

cd "$(dirname "$0")"
clear_results
