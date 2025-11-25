#!/usr/bin/env sh

set -eu

print_help() {
	printf 'This is a simple script that just prints the list of all tests.\n'
	printf '\n'
	printf 'Usage: %s [-h | --help | -e | --essential | -E | --non_essential]\n\t[ -R | --relative] [-c | --changed] [-C X | --changed-since=X]\n' "$(basename "$0")"
	printf 'Options:\n'
	printf '    -a, --altered\t- Print only the tests changed since the last commit.\n\t\t\t  (Only changes in individual test files count, not in\n\t\t\t  the common test utilities that affect every test.)\n\t\t\t  (See also "--since".)\n'
	printf '    -A, --since=X\t- Selects the commit used as reference by "--altered".\n\t\t\t  Empty string means INDEX. (It implies "--altered".)\n'
	printf '    -e, --essential\t- Print only the tests marked as essential.\n'
	printf '    -E, --non-essential\t- Print only the tests NOT marked as essential.\n'
	printf '    -h, --help\t\t- Print this help text.\n'
	printf '    -R, --relative\t- Print paths relative to the current directory.\n'
	printf '    -v, --version\t- Print version information and exit.\n'
}

print_version() {
	printf 'test listing script version 1.0.2\n'
}

getopt_short_options='aA:eEhRv'
getopt_long_options='altered,since:,essential,non-essential,help,relative,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
only_changed=n
changed_reference=HEAD
essential=n
non_essential=n
relative_dir_prefix=''
while true
do
	case "$1" in
	-a|--altered)
		only_changed=y
		;;
	-A|--since)
		shift
		changed_reference="$1"
		only_changed=y
		;;
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

find . -mindepth 2 -maxdepth 2 -type f -name '*.sh' ! -path './remote-for-tests/*' ! -path './the-actual-git/*' \
| cut -c3- \
| {
	if [ "$only_changed" = n ]
	then
		cat
	elif printf '%s ' "$changed_reference" | grep -q '^\s*$'
	then
		xargs -- git --literal-pathspecs diff --no-renames --name-only --
	else
		xargs -- git --literal-pathspecs diff --no-renames --name-only "$changed_reference" --
	fi
} | {
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
| sort \
| sed "s;^;$relative_dir_prefix;"
