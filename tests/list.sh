#!/usr/bin/env sh

set -eu

print_help() {
	printf 'This is a simple script that just prints the list of all tests.\n'
	printf '\n'
	printf 'Usage: %s ([-h | --help | --version)\n' "$(basename "$0")"
	printf '   or: %s [ -e | --essential | -E | --non_essential] [ -R | --relative]\n\t[-c | --changed] [-C X | --changed-since=X] [--] [<filter>...]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -a, --altered\t- Print only the tests changed since the last commit.\n\t\t\t  (Only changes in individual test files count, not in\n\t\t\t  the common test utilities that affect every test.)\n\t\t\t  Renamed tests with 100%% similarity are omitted.\n\t\t\t  (See also "--since".)\n'
	printf '    -A, --since=X\t- Selects the commit used as reference by "--altered".\n\t\t\t  (It implies "--altered".)\n\t\t\t  Special cases:\n\t\t\t  * Empty / blank string means INDEX.\n\t\t\t  * Strings starting with "~" or "^" imply HEAD.\n\t\t\t    (So "~2" means the same as "HEAD~2".)\n\t\t\t  * "-" means all changes since branching from "master".\n'
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
	printf 'test listing script version 1.1.0\n'
}

find_master() {
	if git rev-parse --verify --quiet 'master^{commit}' 1>/dev/null
	then
		printf 'master'
	else
		remote_branches="$(git for-each-ref --format='%(refname)' "refs/remotes/*/master")"
		if [ -z "$remote_branches" ]
		then
			printf 'Cannot find the master branch!\n' 1>&2
			return 1
		elif [ "$(printf '%s\n' "$remote_branches" | wc -l)" -gt 1 ]
		then
			if ! default_remote="$(git config --get checkout.defaultRemote)"
			then
				printf 'Multiple remotes have the master branch and there is no "checkout.defaultRemote"!\n' 1>&2
				return 1
			fi
			if ! remote_branches="$(printf '%s' "$remote_branches" | grep -E "^refs/remotes/$default_remote/")"
			then
				printf 'Multiple remotes have the master branch and none of them are "checkout.defaultRemote"!\n' 1>&2
				return 1
			fi
		fi
		printf '%s' "$remote_branches" | sed -E 's;^refs/remotes/;;'
	fi
}

getopt_short_options='aA:eEhRv'
getopt_long_options='altered,since:,essential,non-essential,help,relative,version'
normalized_options="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$normalized_options"
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
		if printf '%s' "$changed_reference" | grep -qE '^[~^]'
		then
			changed_reference="HEAD$changed_reference"
		elif [ "$changed_reference" = '-' ]
		then
			changed_reference="$(find_master)...HEAD"
		fi
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

{
	if [ "$only_changed" = n ]
	then
		find . -mindepth 2 -maxdepth 2 -type f -name '*.sh' ! -path './remote-for-tests/*' ! -path './the-actual-git/*' \
		| cut -c3-
	else
		find . -mindepth 1 -maxdepth 1 -type d ! -name 'remote-for-tests' ! -name 'the-actual-git' \
		| if printf '%s ' "$changed_reference" | grep -q '^\s*$'
		then
			xargs -- git --literal-pathspecs diff -M --name-status --relative --
		else
			xargs -- git --literal-pathspecs diff -M --name-status --relative "$changed_reference" --
		fi \
		| sed -E -e '/^R100\t/d' \
			-e '/^D\t/d' \
			-e 's/^[CR][0-9]{3}\t(\S+)\t(\S+)$/A\t\2/' \
		| cut -c3- \
		| grep -E '^[^/]+/[^/]+\.sh$' || true
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
