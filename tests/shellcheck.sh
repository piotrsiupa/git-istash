#!/usr/bin/env sh

set -e

cd "$(dirname "$0")"

list_files() {
	find ../scripts -maxdepth 1 -type f -not -name '.*'
	find . -maxdepth 1 -type f -name '*.sh'
}

if list_files | xargs -- shellcheck
then
	printf 'All %i files are correct.\n' "$(list_files | wc -l)"
	exit 0
else
	exit 1
fi
