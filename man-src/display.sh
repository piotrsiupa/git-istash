#!/usr/bin/env sh

set -e

if [ "$1" = '--help' ]
then
	printf '%s - A developer script that builds and diplays the (only) man page\n    for this repository "share/man/man1/git-istash.1.gz".\n' "$(basename "$0")"
	printf '\n'
	printf 'Usage: %s [--help]\n' "$(basename "$0")"
	exit 0
elif [ $# -ne 0 ]
then
	printf 'error: This script doesn'\''t accept arguments.\n' 1>&2
	exit 1
fi

cd "$(dirname "$0")"

export MANPATH="$(pwd)"
exec man git-istash
