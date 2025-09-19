#!/usr/bin/env sh

set -eu

print_help() {
	printf 'This script helps find all the scripts that should have the version number updated.\n'
	printf 'It assumes that a merge to the master branch is currently in progress; it may not work correctly in other situations.\n'
	printf '\n'
	printf 'Usage: %s [-h | --help | -v | --version]\n' "$(basename "$0")"
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help text.\n'
	printf '    -v, --version\t- Print version information and exit.\n'
}

print_version() {
	printf 'version number update reminder script version 1.0.1\n'
}

find_scripts_to_update_versions() {
	regex='\<print_version\>'
	changed_files="$(git status --porcelain --no-renames | grep -vE 'D  ' | cut -c4- | grep -vE '^tests/.*/')"
	{
		printf '%s\n' "$changed_files" | xargs -- grep -El "$regex" -- | grep -vFx 'releasing-new-version.md'
		if printf '%s\n' "$changed_files" | xargs -- grep -EL "$regex" -- | grep -qE '^lib/'
		then
			printf 'bin/git-istash\n'
		fi
		if printf '%s\n' "$changed_files" | xargs -- grep -EL "$regex" -- | grep -qE '^tests/'
		then
			printf 'tests/run.sh\n'
		fi
	} | sort -u
}

getopt_short_options='hv'
getopt_long_options='help,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
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

cd "$(dirname "$0")"

find_scripts_to_update_versions
