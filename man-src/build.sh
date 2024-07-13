#!/usr/bin/env sh

set -e

if [ "$1" = '--help' ]
then
	printf '%s - A simple script to build "share/man" out of "man-src".\n' "$(basename "$0")"
	printf '\n'
	printf 'Usage: %s [--help]\n' "$(basename "$0")"
	exit 0
elif [ $# -ne 0 ]
then
	printf 'error: This script doesn'\''t accept arguments.\n' 1>&2
	exit 1
fi

cd "$(dirname "$0")"

find . -type f -path './man?/*.?' \
| while read -r source
do
	target="$(printf '%s' "$source" | sed -e 's;^\.;../share/man;' -e 's/$/.gz/')"
	mkdir -p "$(dirname "$target")"
	gzip -c "$source" >"$target"
done
