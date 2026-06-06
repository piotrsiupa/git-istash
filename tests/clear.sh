#!/usr/bin/env sh

set -eu

print_help() {
	printf '%s - A script to remove all the tests results.\n' "${0##*/}"
	printf '(This has no purpose except visually clearing the directories. '
	printf 'Other scripts can\nwork around existing test results no problem, or even use them.)\n'
	printf '\n'
	printf 'Usage: %s [<options...>]\n' "${0##*/}"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help text and exit.\n'
	printf '    -V, --version\t- Print version information and exit.\n'
}

print_version() {
	printf 'tests cleanup script version 1.0.4\n'
}

clear_results() {
	find . -mindepth 2 -maxdepth 2 -type d -name 't_dir__*' -exec rm -rf {} +
}

getopt_short_options='hV'
getopt_long_options='help,version'
normalized_options="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"${0##*/}" -ssh -- "$@")"
eval set -- "$normalized_options"
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
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
	exit 1
fi

cd "$(dirname "$0")"
clear_results
