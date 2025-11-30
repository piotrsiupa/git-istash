#!/usr/bin/env sh

set -eu

print_help() {
	printf 'This is a simple script that just prints the list of all tests.\n'
	printf '\n'
	printf 'Usage: %s [-h | --help | -e | --essential | -E | --non_essential]\n\t[ -R | --relative] [-c | --changed] [-C X | --changed-since=X]\n\t[--] [<filter>...]\n' "$(basename "$0")"
	printf 'Options:\n'
	printf '    -a, --altered\t- Print only the tests changed since the last commit.\n\t\t\t  (Only changes in individual test files count, not in\n\t\t\t  the common test utilities that affect every test.)\n\t\t\t  (See also "--since".)\n'
	printf '    -A, --since=X\t- Selects the commit used as reference by "--altered".\n\t\t\t  Empty string means INDEX. (It implies "--altered".)\n'
	printf '    -e, --essential\t- Print only the tests marked as essential.\n'
	printf '    -E, --non-essential\t- Print only the tests NOT marked as essential.\n'
	printf '    -h, --help\t\t- Print this help text.\n'
	printf '    -R, --relative\t- Print paths relative to the current directory.\n'
	printf '    -v, --version\t- Print version information and exit.\n'
	printf '\n'
	printf 'Filters:\n'
	printf 'Filters can be used to print only some of the tests.\n'
	printf 'See "%s/run.sh --help" for more information.\n' "$(dirname "$0")"
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

normalize_filter_entry() { # filter_entry
	if [ -f "$1" ]
	then
		printf '%s' "$1" \
		| sed -E -e 's;^.*/([^/]+/[^/]+)$;\1;' \
			-e 's;^[^/]+$;./&;' \
			-e "s;^\\./;$(basename "$(pwd)")/;" \
			-e 's/\.sh$//' \
			-e 's/^/^/' -e 's/$/$/'
	else
		printf '%s' "$1"
	fi
}
filter=''
negative_filter=''
while [ $# -ne 0 ]
do
	if printf '%s' "$1" | grep -E -v -q '^-'
	then
		if [ -n "$filter" ]
		then
			filter="$filter|"
		fi
		filter="$filter($(normalize_filter_entry "$(printf '%s' "$1" | sed 's/^\\-/-/')"))"
	else
		if [ -n "$negative_filter" ]
		then
			negative_filter="$negative_filter|"
		fi
		negative_filter="$negative_filter($(normalize_filter_entry "$(printf '%s' "$1" | cut -c2-)"))"
	fi
	shift
done

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
	if [ -n "$filter" ] || [ -n "$negative_filter" ]
	then
		if [ -z "$negative_filter" ]
		then
			negative_filter='^$'
		fi
		sed -E 's/\.sh$//' \
		| grep -E -- "$filter" \
		| grep -E -v -- "$negative_filter" \
		| sed -E 's/$/.sh/'
	else
		cat
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
