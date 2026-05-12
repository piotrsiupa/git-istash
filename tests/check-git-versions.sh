#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/facets.sh"

actual_git_repo_path='./the-actual-git'
subsequent_failed_version_limit=5

print_help() {
	printf 'This tests downloads the Git repository, compiles all the versions, starting at\nthe newest one and tries to run tests of each one of them.\n'
	printf 'It run tests at meticulousness up to "complete". '
	printf 'If %i mayor version didn'\''t work\nthe script stops.\n' "$subsequent_failed_version_limit"
	printf 'The goal is to determine which versions of Git are supported by istash.\n'
	printf '\n'
	printf 'Usage: %s [-h | --help | -Q | --quick | -V | --version] [--] [<free_arg...>]\n' "$(basename "$0")"
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help text end exit.\n'
	printf '    -l, --list\t\t- List all available Git versions and do nothing else.\n'
	printf '    -m, --meticulous=X\t- Set how many tests / test variants will be run.\n\t\t\t  (For more info, run "run.sh --help".)\n\t\t\t  Use ";" to define a few rounds of tests.\n'
	printf '    -Q, --quick\t\t- Use binary search to try to find the oldest supported\n\t\t\t  version of Git without thoroughly testing all of them.\n'
	printf '    -s, --single=<ver>\t- Check only the given version and use "monitor.sh"\n\t\t\t  instead of "run.sh".\n'
	printf '    -V, --version\t- Print version information and exit.\n'
	printf '\t<free_arg>\t- Any additional arguments are passed to the underlying\n\t\t\t  "run.sh" or "monitor.sh".\n'
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
	printf '\033[1mVersion %s\t...\033[0m (compiling)' "${version#v}"
	if (
		cd "$actual_git_repo_path"
		git switch --detach "$version" 1>/dev/null 2>&1
		make -j "$(nproc)" 1>/dev/null 2>&1
	)
	then
		printf '\r\033[16C\033[0K'
		return 0
	else
		printf '\r\033[16C\033[41mFAILED\033[49m (Cannot compile Git.)\n'
		return 1
	fi
}

clear_lines_up() { # line_count
	printf '\033[%iA\033[0J' "$1"
}
_run_tests_with_args() { # [arg_to_ignore...] -- [free_arg...]
	while [ "$1" != '--' ]
	do
		shift
	done
	shift
	set +e
	PATH="$new_PATH" ./run.sh --meticulousness="$current_meticulousness" --check --progress --skip-version --jobs=0 --color=always "$@" 2>/dev/null
	exit_code=$?
	set -e
	clear_lines_up 1
	return $exit_code
}
check_version() { # meticulousnesses... -- [free_arg...]
	if ! compile_version
	then
		return 1
	else
		if [ -n "$meticulousness" ]
		then
			eval set -- "$(
				printf '%s' "$meticulousness" \
				| sed -E -e 's/^.+$/'\''&'\''/' -e 's/;/'\'' '\''/g'
				while [ "$1" != '--' ]
				do
					shift
				done
				printf ' '\''%s'\' "$@"
			)"
		fi
		printf '\n'
		run_counter=0
		for current_meticulousness in "$@"
		do
			if [ "$current_meticulousness" = '--' ]
			then
				break
			fi
			printf '\033[1mRunning tests with meticulousness "%s"...\033[0m\n' "$current_meticulousness"
			run_counter=$((run_counter + 1))
			if ! _run_tests_with_args "$@"
			then
				clear_lines_up $run_counter
				printf '\033[1A\033[16C\033[31mFAILED\033[39m (Failed at meticulousness "%s")\n' "$current_meticulousness"
				return 1
			fi
		done
	fi
	clear_lines_up $run_counter
	printf '\033[1A\033[16C\033[32mPASSED\033[39m\n'
	return 0
}

check_versions_one_by_one() { # [free_arg...]
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
		if check_version 'minimal' 'complete' -- "$@"
		then
			any_minor_version_succeeded=y
		fi
	done
}

check_versions_binary_search() { # [free_arg...]
	versions="$(get_all_versions '')"
	versions_num="$(printf '%s\n' "$versions" | wc -l)"
	last_is_tested=0
	while true
	do
		printf 'Remaining versions: %i (expected steps: %i)...\n' "$((versions_num - last_is_tested))" "$(printf '(l(%i) / l(2)) + 1\n' "$((versions_num - last_is_tested))" | bc -l | sed 's/\..*$//')"
		middle=$(((versions_num - last_is_tested + 1) / 2))
		version="$(printf '%s\n' "$versions" | tail -n "+$middle" | head -n 1)"
		if check_version 'complete' -- "$@"
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

monitor_single_version() { # [free_arg...]
	if ! get_all_versions '' | grep -Exq "$single_version"
	then
		printf 'There is no version %s!\n' "$single_version" 2>&1
		exit 1
	fi
	version="$single_version"
	if compile_version
	then
		printf '\n'
		if [ -n "$meticulousness" ]
		then
			set -- -m "$meticulousness" "$@"
		fi
		PATH="$new_PATH" exec ./monitor.sh "$@"
	fi
}

check_versions() { # [free_arg...]
	abs_actual_git_repo_path="$(cd "$actual_git_repo_path" ; pwd)"
	if [ "$list_versions" = y ]
	then
		get_all_versions ''
		exit 0
	fi
	new_PATH="$abs_actual_git_repo_path:$PATH"
	if [ "$quickie" = y ]
	then
		check_versions_binary_search "$@"
	elif [ -n "$single_version" ]
	then
		monitor_single_version "$@"
	else
		check_versions_one_by_one "$@"
	fi
}

getopt_short_options='hlm:Qs:V'
getopt_long_options='help,list-versions,meticulous:,quickie,single-version:,version'
normalized_options="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$normalized_options"
list_versions=n
meticulousness=''
quickie=n
single_version=''
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
		;;
	-l|--list-versions)
		list_versions=y
		;;
	-m|--meticulous)
		shift
		#shellcheck disable=SC2020
		printf '%s\n' "$1" \
		| tr '|;' '\n\n' \
		| sed -E '/^(quickie|complete)$/d' \
		| while read -r x
		do
			parse_meticulousness "$x" 1>/dev/null
		done
		meticulousness="$1"
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
if [ "$quickie" = y ] && [ -n "$single_version" ]
then
	printf '"--quickie" and "--single" are not compatible!\n' 1>&2
	exit 1
fi
if [ "$list_versions" = y ] && [ -n "$single_version" ]
then
	printf '"--list" and "--single" are not compatible!\n' 1>&2
	exit 1
fi
if printf '%s' "$meticulousness" | grep -E -q ';' && [ -n "$single_version" ]
then
	printf 'Multiple rounds of meticulousness don'\''t apply to the single version mode!\n' 1>&2
	exit 1
fi

cd "$(dirname "$0")"
prepare_git_repo
check_versions "$@"
