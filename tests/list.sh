#!/usr/bin/env sh

set -e

print_help() {
	printf 'This is a simple script that just prints the list of all tests.\n'
	printf '\n'
	printf 'Usage: %s [-h | --help | -e | --essential | -E | --non_essential]\n\t[ -R | --relative]\n' "$(basename "$0")"
	printf 'Options:\n'
	printf '    -e, --essential\t- Print only the tests marked as essential.\n'
	printf '    -E, --non-essential\t- Print only the tests NOT marked as essential.\n'
	printf '    -h, --help\t\t- Print this help text.\n'
	printf '    -R, --relative\t- Print paths relative to the current directory.\n'
	printf '    -v, --version\t- Print version information and exit.\n'
}

print_version() {
	printf 'test listing script version 1.0.0\n'
}

getopt_short_options='eEhRv'
getopt_long_options='essential,non-essential,help,relative,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
essential=n
non_essential=n
relative_dir_prefix=''
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
	-R|--relative)
		relative_dir_prefix="$(dirname "$0")/"
		;;
	-v|--version)
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

find . -mindepth 2 -maxdepth 2 -type f -name '*.sh' ! -path './remote-for-tests/*' ! -path './the-actual-git/*' | cut -c3- | sort \
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
} \
| sed "s;^;$relative_dir_prefix;"
