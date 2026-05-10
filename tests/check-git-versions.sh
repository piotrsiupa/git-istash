#!/usr/bin/env sh

set -eu

actual_git_repo_path='./the-actual-git'
subsequent_failed_version_limit=5

print_help() {
	printf 'This tests downloads the Git repository, compiles all the versions, starting at\nthe newest one and tries to run tests of each one of them.\n'
	printf 'It run tests at meticulousness up to "complete". '
	printf 'If %i mayor version didn'\''t work\nthe script stops.\n' "$subsequent_failed_version_limit"
	printf 'The goal is to determine which versions of Git are supported by istash.\n'
	printf '\n'
	printf 'Usage: %s [-h | --help | -Q | --quick | -V | --version]\n' "$(basename "$0")"
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help text end exit.\n'
	printf '    -Q, --quick\t\t- Use binary search to try to find the oldest supported\n\t\t\t  version of Git without thoroughly testing all of them.\n'
	printf '    -s, --single=<ver>\t- Check only the given version and use "monitor.sh"\n\t\t\t  instead of "run.sh".\n'
	printf '    -V, --version\t- Print version information and exit.\n'
}

print_version() {
	printf 'Git version checking script version 1.2.0\n'
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
compile_version() {
	printf 'Version %s\t...' "${version#v}"
	if ! (
		cd "$actual_git_repo_path"
		git switch --detach "$version" 1>/dev/null 2>&1
		make -j "$(nproc)" 1>/dev/null 2>&1
	)
	then
		printf '\b\b\b\033[41mFAILED\033[49m (Cannot compile Git.)\n'
		return 1
	fi
}
check_version() { # meticulousnesses...
	if ! compile_version
	then
		return 1
	else
		for x in "$@"
		do
			if ! PATH="$new_PATH" ./run.sh --meticulousness="$x" --check --skip-version --jobs=0 1>/dev/null 2>&1
			then
				printf '\b\b\b\033[31mFAILED\033[39m (Failed at meticulousness "%s")\n' "$x"
				return 1
			fi
		done
	fi
	printf '\b\b\b\033[32mPASSED\033[39m\n'
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
		if check_version 'minimal' 'complete'
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
		if check_version 'complete'
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
		printf '\033[1mThe first compatible version seems to be \033[32m%s\033[39m.\033[0m\n' "${versions#v}"
	else
		printf '\033[1mIt seems that there are \033[31mNO\033[39m compatible versions.\033[0m\n'
	fi
}
monitor_single_version() {
	if ! get_all_versions '' | grep -Exq "$single_version"
	then
		printf 'There is no version %s!\n' "$single_version" 2>&1
		exit 1
	fi
	version="$single_version"
	if compile_version
	then
		printf '\n'
		PATH="$new_PATH" exec ./monitor.sh
	fi
}
check_versions() {
	abs_actual_git_repo_path="$(cd "$actual_git_repo_path" ; pwd)"
	new_PATH="$abs_actual_git_repo_path:$PATH"
	if [ "$quickie" = y ]
	then
		check_versions_binary_search
	elif [ -n "$single_version" ]
	then
		monitor_single_version
	else
		check_versions_one_by_one
	fi
}

getopt_short_options='hQs:V'
getopt_long_options='help,quickie,single-version:,version'
normalized_options="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$normalized_options"
quickie=n
single_version=''
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
	-s|--single-version)
		shift
		if ! printf '%s' "$1" | grep -Eqx 'v?[0-9]+\.[0-9]+\.[0-9]'
		then
			printf '"%s" is not a version number!\n' "$1" 1>&2
			exit 1
		fi
		single_version="v${1#v}"
		;;
	-V|--version)
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
if [ "$quickie" = y ] && [ -n "$single_version" ]
then
	printf '"--quickie" and "--single" are not compatible!\n' 1>&2
	exit 1
fi

cd "$(dirname "$0")"
prepare_git_repo
check_versions
