#!/usr/bin/env sh

set -e

cd "$(dirname "$0")"
results_file='./results.txt'
scripts_dir='../scripts'

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
	git init "$test_dir"
	git -C "$test_dir" config --local user.email 'test@localhost'
	git -C "$test_dir" config --local user.name 'test'
	git -C "$test_dir" commit --allow-empty -m 'Initial commit'
}

run_test() { # test_name
	cleanup_test "$1"
	create_test_dir "$1" 1>/dev/null
	if "./$(get_test_script "$1")" "$(get_test_dir "$1")" 1>/dev/null 2>&1
	then
		printf '\e[32mPASSED - "%s"\e[0m\n' "$(printf '%s' "$1" | tr '_' ' ')"
		cleanup_test "$1"
	else
		printf '\e[31mFAILED - "%s"\e[0m (the result is kept)\n' "$(printf '%s' "$1" | tr '_' ' ')"
	fi
}
run_tests() { # pattern
	find . -maxdepth 1 -type f -name 'test_*.sh' \
	| xargs -rn1 -- basename | rev | cut -c4- | rev | cut -c6- \
	| grep -P "$1" \
	| sort \
	| while read -r test_name
	do
		run_test "$test_name"
	done
}

print_summary() { # results_file
	total_tests="$(wc -l <"$1")"
	passed_tests="$(grep -c 'PASSED' <"$1" || true)"
	if [ "$total_tests" -ne 0 ]
	then
		printf -- '----------------\n'
		if [ "$passed_tests" -eq "$total_tests" ]
		then
			printf '\e[32m'
		else
			printf '\e[31m'
		fi
		printf 'Passed %i out of %i tests.\e[0m\n' "$passed_tests" "$total_tests"
	else
		printf '\e[33mNo matching tests were found!\e[0m\n'
	fi
}

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
export PATH="$(realpath "$scripts_dir"):$PATH"
run_tests "$filter" | tee "$results_file"
print_summary "$results_file"
rm -f "$results_file"
