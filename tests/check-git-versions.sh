#!/usr/bin/env sh

set -eu

actual_git_repo_path='./the-actual-git'
subsequent_failed_version_limit=5
meticulousness=2

print_help() {
	printf 'This tests downloads the Git repository, compiles all the versions, starting at\nthe newest one and tries to run tests of each one of them.\n'
	printf 'It run tests at meticulousness %i. ' "$meticulousness"
	printf 'If %i mayor version didn'\''t work the script\nstops.\n' "$subsequent_failed_version_limit"
	printf 'The goal is to determine which versions of Git are supported by istash.\n'
	printf '\n'
	printf 'Usage: %s [-h | --help | -Q | --quick | --version]\n' "$(basename "$0")"
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help message end exit.\n'
	printf '    -Q, --quick\t\t- Use binary search to try to find the oldest supported\n\t\t\t  version of Git without thoroughly testing all of them.\n'
	printf '\t--version\t- Print version information and exit.\n'
}

print_version() {
	printf 'Git version checking script version 1.1.0\n'
}

prepare_git_repo() {
	if [ ! -d "$actual_git_repo_path" ]
	then
		git clone --no-tags --single-branch --depth=1 'https://github.com/git/git' "$actual_git_repo_path"
	fi
	git -C "$actual_git_repo_path" fetch --no-tags origin '+refs/tags/v*:refs/tags/v*'
}

get_all_versions() { # sort_prefix
	git -C "$actual_git_repo_path" tag --sort="$1version:refname" | grep -E '^v[1-9][0-9.]+$'
}
strip_tag_version() { # tag_version_number
	printf '%s' "$1" | cut -c2-
}
print_success() {
	printf '\b\b\b\033[32mPASSED\033[39m\n'
}
print_failure() {  # reason
	printf '\b\b\b\033[31mFAILED\033[39m (%s)\n' "$1"
}
check_version() { # meticulousnesses...
	printf 'Version %s\t...' "$(strip_tag_version "$version")"
	if ! (
		cd "$actual_git_repo_path"
		git switch --detach "$version" 1>/dev/null 2>&1
		make -j "$(nproc)" 1>/dev/null 2>&1
	)
	then
		print_failure 'Cannot compile Git.'
		return 1
	else
		for i in "$@"
		do
			if ! PATH="$abs_actual_git_repo_path:$PATH" ./run.sh --meticulousness="$i" --check --skip-version --jobs=0 1>/dev/null 2>&1
			then
				print_failure "Failed at meticulousness $i"
				return 1
			fi
		done
	fi
	print_success
	return 0
}
check_versions_one_by_one() {
	last_mayor_version=''
	any_minor_version_succeeded=y
	get_all_versions '-' \
	| while read -r version
	do
		mayor_version="$(printf '%s' "$version" | sed -E 's/^(v[0-9]+\.[0-9]+)(\..*)?$/\1/')"
		if [ "$mayor_version" != "$last_mayor_version" ]
		then
			if [ "$any_minor_version_succeeded" = n ]
			then
				subsequen_failure_count=$((subsequen_failure_count + 1))
				if [ "$subsequen_failure_count" -eq "$subsequent_failed_version_limit" ]
				then
					printf '%i versions failed in a row... that'\''s the limit... finishing...\n' "$subsequent_failed_version_limit"
					break
				fi
			else
				subsequen_failure_count=0
			fi
			last_mayor_version="$mayor_version"
			any_minor_version_succeeded=n
		fi
		if check_version "$meticulousness"
		then
			any_minor_version_succeeded=y
		fi
	done
}
check_versions_binary_search() {
	versions="$(get_all_versions '')"
	versions_num="$(printf '%s\n' "$versions" | wc -l)"
	last_is_tested=0
	while true
	do
		printf 'Remaining versions: %i (expected steps: %i)...\n' "$((versions_num - last_is_tested))" "$(printf '(l(%i) / l(2)) + 1\n' "$((versions_num - last_is_tested))" | bc -l | sed 's/\..*$//')"
		middle=$(((versions_num - last_is_tested + 1) / 2))
		version="$(printf '%s\n' "$versions" | tail -n "+$middle" | head -n 1)"
		if check_version "$meticulousness"
		then
			versions="$(printf '%s\n' "$versions" | head -n "$middle")"
			versions_num="$middle"
			if [ "$versions_num" -eq 1 ]
			then
				break
			fi
			last_is_tested=1
		else
			versions="$(printf '%s\n' "$versions" | tail -n "+$((middle + 1))")"
			versions_num=$((versions_num - middle))
			if [ "$versions_num" -eq 0 ] || { [ "$versions_num" -eq 1 ] && [ "$last_is_tested" -eq 1 ] ; }
			then
				break
			fi
		fi
	done
	if [ "$versions_num" -eq 1 ]
	then
		printf '\033[1mThe first compatible version seems to be \033[32m%s\033[39m.\033[0m\n' "$(strip_tag_version "$versions")"
	else
		printf '\033[1mIt seems that there are \033[31mNO\033[39m compatible versions.\033[0m\n'
	fi
}
check_versions() {
	abs_actual_git_repo_path="$(cd "$actual_git_repo_path" ; pwd)"
	if [ "$quickie" = n ]
	then
		check_versions_one_by_one
	else
		check_versions_binary_search
	fi
}

getopt_short_options='hQ'
getopt_long_options='help,quickie,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
quickie=n
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
		;;
	-Q|--quickie)
		quickie=y
		;;
	--version)
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
if [ $# -ne 0 ]
then
	printf 'This script doesn'\''t take non-option arguments!\n' 1>&2
	exit 1
fi

cd "$(dirname "$0")"
prepare_git_repo
check_versions
