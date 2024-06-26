#!/usr/bin/env sh

set -e

cd "$(dirname "$0")"
scripts_dir='../scripts'

print_color_code() { # code
	if [ "$use_color" -ne 0 ]
	then
		#shellcheck disable=SC2059
		printf "$1"
	fi
}

get_test_script() { # test_name
	printf 'test_%s.sh' "$1"
}
get_test_dir() { # test_name
	printf 't_dir_%s' "$1"
}

cleanup_test() { # test_name
	rm -rf "$(get_test_dir "$1")"
}
create_test_dir() { # test_name
	test_dir="$(get_test_dir "$1")"
	git init --initial-branch=master "$test_dir"
	git -C "$test_dir" config --local user.email 'test@localhost'
	git -C "$test_dir" config --local user.name 'test'
	git -C "$test_dir" commit --allow-empty -m 'Initial commit'
}

find_tests() { # pattern
	find . -maxdepth 1 -type f -name 'test_*.sh' -print0 \
	| xargs -r0n1 -- basename | rev | cut -c4- | rev | cut -c6- \
	| grep -P "$1" \
	| while read -r test_name
	do
		if [ "$only_failed" -eq 0 ] || [ -d "$(get_test_dir "$test_name")" ]
		then
			printf '%s\n' "$test_name"
		fi
	done \
	| sort
}

run_test() { # test_name
	cleanup_test "$1"
	create_test_dir "$1" 1>/dev/null
	exec 4>&1
	test_passed="$(
		if ! cd "$(get_test_dir "$1")"
		then
			printf '0' 1>&4
		elif [ "$debug_mode" -eq 0 ]
		then
			if "../$(get_test_script "$1")" 1>/dev/null 2>&1
			then
				printf '1' 1>&4
			else
				printf '0' 1>&4
			fi
		else
			{
				if "../$(get_test_script "$1")"
				then
					printf '1' 1>&4
				else
					printf '0' 1>&4
				fi 5>&2 2>&1 1>&5 5>&- \
				| if [ "$use_color" -ne 0 ]
				then
					sed -u 's/^.*$/\t\x1B[31m&\x1B[39m/'
				else
					sed -u 's/^/\t/'
				fi
			} 5>&2 2>&1 1>&5 5>&- | sed -u 's/^/\t/'
		fi 5>&4 4>&1 1>&5 5>&-
	)"
	exec 4>&-
	if [ "$raw_name" -eq 0 ]
	then
		display_name="\"$(printf '%s' "$1" | tr '_' ' ')\""
	else
		display_name="$(dirname "$0")/test_$1.sh"
	fi
	if [ "$test_passed" -ne 0 ]
	then
		if [ "$quiet_mode" -eq 0 ]
		then
			print_color_code '\e[0;1;32m'
			printf 'PASSED - %s' "$display_name"
			print_color_code '\e[22;39m'
			printf '\n'
		fi
		cleanup_test "$1"
		return 0
	else
		print_color_code '\e[0;1;31m'
		printf 'FAILED - %s' "$display_name"
		print_color_code '\e[22;39m'
		printf ' (the result is kept)\n'
		return 1
	fi
}
run_tests() { # pattern
	exec 3>&1
	passed_tests="$(
		find_tests "$1" \
		| while read -r test_name
		do
			if run_test "$test_name" 1>&3
			then
				printf '1'
			fi
		done | head -n 1 | wc -c
	)"
	exec 3>&-
}

print_summary() {
	if [ "$total_tests" -ne 0 ]
	then
		if [ "$passed_tests" -eq "$total_tests" ]
		then
			print_color_code '\e[42;1;32;4m'
			printf 'Passed all %i tests.' "$total_tests"
		else
			print_color_code '\e[41;2;31;4m'
			printf 'Passed %i out of %i tests.' "$passed_tests" "$total_tests"
		fi
	else
		print_color_code '\e[43;1;33;4m'
		printf 'No matching tests were found!'
	fi
	print_color_code '\e[0m'
	printf '\n'
}

getopt_result="$(getopt -of --long=failed --long debug -oq --long=quiet -oc: --long=color: --long=raw --long=raw-name --long=file-name -n "$(basename "$0")" -- "$@")"
eval set -- "$getopt_result"
only_failed=0
debug_mode=0
quiet_mode=0
use_color='auto'
raw_name=0
while true
do
	case "$1" in
	--failed)
		only_failed=1
		;;
	--debug)
		debug_mode=1
		;;
	-q|--quiet)
		quiet_mode=1
		;;
	-c|--color)
		shift
		if printf '%s' "$1" | grep -ixq 'auto\|default'
		then
			use_color='auto'
		elif printf '%s' "$1" | grep -ixq 'yes\|always\|true\|1'
		then
			use_color=1
		elif printf '%s' "$1" | grep -ixq 'no\|never\|false\|0'
		then
			use_color=0
		else
			printf '"%s" is not a valid color setting. (always / never / auto)\n' "$1" 1>&2
			exit 1
		fi
		;;
	--raw|--raw-name|--file-name)
		raw_name=1
		;;
	--)
		shift
		break
		;;
	esac
	shift
done
if [ "$use_color" = 'auto' ]
then
	if [ -t 1 ] && [ -t 2 ]
	then
		use_color=1
	else
		use_color=0
	fi
fi
if [ $# -eq 0 ]
then
	filter=''
else
	filter="($1)"
	shift
	while [ $# -ne 0 ]
	do
		filter="$filter|($1)"
		shift
	done
fi

test -d "$scripts_dir"
PATH="$(realpath "$scripts_dir"):$PATH"
total_tests="$(find_tests "$filter" | wc -l)"
export PATH
run_tests "$filter"
print_summary
if [ "$total_tests" -ne 0 ] && [ "$passed_tests" -eq "$total_tests" ]
then
	exit 0
else
	exit 1
fi
