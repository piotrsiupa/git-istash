#!/usr/bin/env sh

set -e

print_help() {
	printf 'This is a simple script that just prints the list of all tests.\n'
	printf '\n'
	printf 'Usage:\t%s [-h | --help | -e | --essential | -E | --non_essential]\n' "$(basename "$0")"
	printf 'Options:\n'
	printf '    -e, --essential\t- Print only the tests marked as essential.\n'
	printf '    -E, --non-essential\t- Print only the tests NOT marked as essential.\n'
	printf '    -h, --help\t\t- Print this help text.\n'
}

getopt_short_options='eEh'
getopt_long_options='essential,non-essential,help'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
essential=n
non_essential=n
while true
do
	case "$1" in
	-e|--essential)
		essential=y
		;;
	-E|--non-essential)
		non_essential=y
		;;
	-h|--help)
		print_help
		exit 0
		;;
	--)
		shift
		break
		;;
	esac
	shift
done
if [ "$essential" = y ] && [ "$non_essential" = y ]
then
	printf 'Options "--essential" and "--non-essential" are incompatible!\n' 1>&2
	exit 1
fi
if [ $# -ne 0 ]
then
	printf 'Non-option arguments are not allowed!\n' 1>&2
	exit 1
fi

cd "$(dirname "$0")"

find . -mindepth 2 -maxdepth 2 -type f -name '*.sh' | cut -c3- | sort \
| {
	non_essential_regex='(^|;)\s*non_essential_test\s*(;|$|#)'
	if [ "$essential" = y ]
	then
		xargs -- grep -EL "$non_essential_regex"
	elif [ "$non_essential" = y ]
	then
		xargs -- grep -El "$non_essential_regex"
	else
		cat
	fi
}
