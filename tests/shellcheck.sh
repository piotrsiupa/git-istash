#!/usr/bin/env sh

set -e

if [ "$1" = '-h' ] || [ "$1" = '--help' ]
then
	printf '%s - Test script that runs "shellcheck" on all shell scripts in this\n    repository. ' "$(basename "$0")"
	printf '(All scripts from directories "scripts" AND "tests".)\n'
	printf '\n'
	printf 'Usage: %s [--help]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t- Print this help message and exit.\n'
	exit 0
elif [ $# -ne 0 ]
then
	printf 'Unrecognised argument "%s".\n' "$1" 1>&2
	exit 1
fi

cd "$(dirname "$0")"

list_files() {
	find ../scripts -type f -not -name '.*'
	find . -maxdepth 2 -type f -name '*.sh'
}

test_dirs="$(find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -r0n1 basename | tr '\n' ':')"  # Not a clean solution but `shellcheck` doesn't support anything better.
if list_files | xargs -- shellcheck --shell=sh --source-path="${test_dirs}../scripts"
then
	printf 'All %i files are correct.\n' "$(list_files | wc -l)"
	exit 0
else
	exit 1
fi
