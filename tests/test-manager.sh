#!/usr/bin/env sh

set -eu

print_help() {
	printf 'A simple script that runs some fancy regexes and such to help with renaming\ntests in a way that keeps their name'\''s prefixes alphabetical.\n'
	printf 'Unlike other tests scripts, this one works relatively to the current directory.\n'
	printf '(The script assumes that existing tests have correct names and may misbehave if\nthey don'\''t.)\n'
	printf '(It also assumes that there is no spaces or weird characters in the names.)\n'
	printf '(And it also assumes that you always refer to the same folder in the same way,\nso e.g. it may mess up order of operation with creating files "./1C_first_test"\nand "1C_second_test".)\n'
	printf '\n'
	printf 'Usage: %s <command> [<option>] [--] <test_name>...\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help message and exit.\n'
	printf '\t--version\t- Print version information and exit.\n'
	printf '\n'
	printf 'Commands:\n'
	printf '\tcreate\t- Add new and empty test files with given names and rename other\n\t\t  tests to keep the prefixes ordered. '
		printf 'You can skip the file\n\t\t  extension and if you want to just stick the test at the end of\n\t\t  a sub-category, you can skip the letters from the prefix too.'
		printf '\n\t\t  (The operations are ordered in such a way that tests will land\n\t\t  in the chosen spots even if the numeration has changed.'
		printf '\n\t\t  If there are multiple tests for the same spot, they will\n\t\t  maintain their relative order.)\n'
	printf '\tdelete\t- Remove the given test and rename other tests to keep the\n\t\t  prefixes ordered. '
		printf '(The operations are ordered in such a way\n\t\t  that the correct tests are removed even if their names change\n\t\t  in the process.)\n'
}

print_version() {
	printf 'tests ranaming script version 1.0.0\n'
}

list_category() { # category_path
	find "$(dirname "$1")" -maxdepth 1 -type f -name '*.sh' -name "$(basename "$1")*" \
	| grep -E '^.*/[0-9]+[A-Z]+_[^/]+\.sh$'
}

extract_category() { # test_name
	printf '%s' "$1" | sed -E 's;^((.*/)?[0-9]+)[A-Z]*_[^/]+$;\1;' | grep '.'
}

extract_prefix() { # test_name_or_its_part
	printf '%s' "$1" | sed -E 's;^(.*/)?([0-9]+[A-Z]+)(_[^/]+)?$;\2;' | grep '.'
}

elongate_prefix() { # test_name_or_prefix
	printf '%s\n' "$1" | sed -E 's;^((.*/)?[0-9]+)([A-Z]+(_[^/]+)?)$;\1A\3;'
}

infinitesimalize_prefix() { # test_name_or_prefix
	printf '%s\n' "$1" | sed -E 's;^((.*/)?[0-9]+)A([A-Z]+(_[^/]+)?)$;\1\3;'
}

# It assumes that there is enough letters.
increment_prefix() { # prefix_or_test_name
	printf '%s' "$1" | sed -E 's;^(.*/)?[0-9]+[A-Z]+(_[^/]+)?$;\1;'
	prefix="$(extract_prefix "$1")"
	printf '%s' "$prefix" | sed -E 's/^([0-9]+[A-Z]*)[A-Y]Z*$/\1/'
	printf '%s' "$prefix" | sed -E 's/^[0-9]+[A-Z]*([A-Y])Z*$/\1/' | tr 'A-Y' 'B-Z'
	printf '%s' "$prefix" | sed -E 's/^[0-9]+[A-Z]*[A-Y](Z*)$/\1/' | tr 'Z' 'A'
	printf '%s' "$1" | sed -E 's;^(.*/)?[0-9]+[A-Z]+(_[^/]+)?$;\2;'
}

decrement_prefix() { # prefix_or_test_name
	printf '%s' "$1" | sed -E 's;^(.*/)?[0-9]+[A-Z]+(_[^/]+)?$;\1;'
	prefix="$(extract_prefix "$1")"
	printf '%s' "$prefix" | sed -E 's/^([0-9]+[A-Z]*)[B-Z]A*$/\1/'
	printf '%s' "$prefix" | sed -E 's/^[0-9]+[A-Z]*([B-Z])A*$/\1/' | tr 'B-Z' 'A-Y'
	printf '%s' "$prefix" | sed -E 's/^[0-9]+[A-Z]*[B-Z](A*)$/\1/' | tr 'A' 'Z'
	printf '%s' "$1" | sed -E 's;^(.*/)?[0-9]+[A-Z]+(_[^/]+)?$;\2;'
}

sort_new_test_names() { # new_test_name...
	printf '%s\n' "$@" \
	| sed -n -E 's;^((.*/)?[0-9]+[A-Z]+)(_[^/]+)$;\1 \3;p' \
	| awk '
		BEGIN {
			count = 0
		}
		{
			if ($1 in files_by_prefix)
			{
				files_by_prefix[$1] = $1 $2 "\n" files_by_prefix[$1]
			}
			else
			{
				files_by_prefix[$1] = $1 $2
				for (i = count; i != 0 && prefixes[i-1] < $1; --i)
				{
					prefixes[i] = prefixes[i-1]
				}
				prefixes[i] = $1
				++count
			}
		}
		END {
			for (i = 0; i != count; ++i)
			{
				print files_by_prefix[prefixes[i]]
			}
		}
	'
	printf '%s\n' "$@" \
	| grep -E '^(.*/)?[0-9]+_[^/]+$' || true
}

create_test() { # new_test_name...
	if [ $# -lt 1 ]
	then
		printf 'You need to specify at least one test name to create!\n' 1>&2
		return 1
	fi
	
	tests_with_bad_names="$(printf '%s\n' "$@" | grep -v -E '^(.*/)?[0-9]+[A-Z]*_[^/]+$' || true)"
	if [ -n "$tests_with_bad_names" ]
	then
		printf 'The test name has to contain at least the number of the sub-category and some text.\n'
		printf 'The following names are bad:\n'
		#shellcheck disable=SC2086
		printf -- ' - "%s"\n' $tests_with_bad_names
		return 1
	fi 1>&2
	
	#shellcheck disable=SC2046
	set -- $(sort_new_test_names "$@")
	
	while [ $# -ne 0 ]
	do
		category="$(extract_category "$1")"
		last_test="$(list_category "$category" | sort -r | head -n 1)"
		last_prefix="$(extract_prefix "$last_test" || true)"
		if printf '%s' "$1" | grep -E -q '^(.*/)?[0-9]+[A-Z]+_[^/]+$'
		then
			new_prefix="$(extract_prefix "$1")"
			if [ -n "$last_prefix" ]
			then
				if [ "${#new_prefix}" -ne "${#last_prefix}" ]
				then
					printf 'The length of the new test'\''s prefix doesn'\''t match existing tests.\n' 1>&2
					return 1
				fi
				if [ "$(printf '%s\n%s\n' "$new_prefix" "$(increment_prefix "$last_prefix")_" | sort -r | head -n1)" = "$new_prefix" ]
				then
					printf 'The prefix of the new test is too big; there would be a gap in tests.\n(The highest available prefix is "%s".)\n' "$(increment_prefix "$last_prefix")" 1>&2
					return 1
				fi
			else
				if [ "${#new_prefix}" != "${category}A" ]
				then
					printf 'The new prefix should be "%s" because it'\''s a new sub-category.\n' "${category}A" 1>&2
					return 1
				fi
			fi
			new_test_name="$1"
		elif printf '%s' "$1" | grep -E -q '^(.*/)?[0-9]+_[^/]+$'
		then
			if [ -n "$last_prefix" ]
			then
				new_prefix="$(increment_prefix "$last_prefix")"
			else
				new_prefix="${category}A"
			fi
			new_test_name="$(printf '%s' "$1" | sed -E 's;^(.*/)?[0-9]+(_[^/]+)$;\1'"$new_prefix"'\2;')"
		fi
		if ! printf '%s' "$new_test_name" | grep -E -q '\.sh$'
		then
			new_test_name="$new_test_name.sh"
		fi
		
		shift
		
		if extract_prefix "$(list_category "$category" | sort -r | head -n1)" | grep -E -q -x '[0-9]+Z+'
		then
			new_prefix="$(elongate_prefix "$new_prefix")"
			new_test_name="$(elongate_prefix "$new_test_name")"
			list_category "$category" \
			| while read -r test_to_rename
			do
				git mv "$test_to_rename" "$(elongate_prefix "$test_to_rename")"
			done
			#shellcheck disable=SC2046
			set -- $(
				printf '%s\n' "$@" \
				| while read -r test_to_rename
				do
					if [ "$(extract_category "$test_to_rename")" = "$category" ]
					then
						elongate_prefix "$test_to_rename"
					else
						printf '%s\n' "$test_to_rename"
					fi
				done
			)
		fi
		
		{
			printf '%s\n' "$(dirname "$new_test_name")/${new_prefix}_" | sed 'p'
			list_category "$category"
		} \
		| sort -r \
		| sed -E -n '1,/\/'"$new_prefix"'_$/p' \
		| grep -v -F -x "$(dirname "$new_test_name")/${new_prefix}_" \
		| while read -r test_to_rename
		do
			git mv "$test_to_rename" "$(increment_prefix "$test_to_rename")"
		done
		
		printf 'touch %s\n' "$new_test_name" 1>&2
		touch "$new_test_name"
		git add --intent-to-add "$new_test_name"
	done
}

delete_test() { # test_name...
	if [ $# -lt 1 ]
	then
		printf 'You need to specify at least one test name to delete!\n' 1>&2
		return 1
	fi
	
	(
		while [ $# -ne 0 ]
		do
			if [ ! -f "$1" ]
			then
				printf 'There'\''s no file "%s"!\n' "$1" 1>&2
				return 1
			fi
			shift
		done
	)
	
	#shellcheck disable=SC2046
	set -- $(printf '%s\n' "$@" | sort -r -u)
	
	while [ $# -ne 0 ]
	do
		category="$(extract_category "$1")"
		deleted_prefix="$(extract_prefix "$1")"
		
		git rm --force "$1"
		
		{
			printf '%s\n' "$(dirname "$1")/${deleted_prefix}_" | sed 'p'
			list_category "$category"
		} \
		| sort \
		| sed -E '1,/\/'"$deleted_prefix"'_$/d' \
		| grep -v -F -x "$(dirname "$1")/${deleted_prefix}_" \
		| while read -r test_to_rename
		do
			git mv "$test_to_rename" "$(decrement_prefix "$test_to_rename")"
		done
		
		shift
		
		if extract_prefix "$(list_category "$category" | sort -r | head -n1)" | grep -E -q '[0-9]A.'
		then
			list_category "$category" \
			| while read -r test_to_rename
			do
				git mv "$test_to_rename" "$(infinitesimalize_prefix "$test_to_rename")"
			done
			#shellcheck disable=SC2046
			set -- $(
				printf '%s\n' "$@" \
				| while read -r test_to_rename
				do
					if [ "$(extract_category "$test_to_rename")" = "$category" ]
					then
						infinitesimalize_prefix "$test_to_rename"
					else
						printf '%s\n' "$test_to_rename"
					fi
				done
			)
		fi
	done
}

getopt_short_options='hs'
getopt_long_options='help,version'
normalized_options="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$normalized_options"
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
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

if [ $# -eq 0 ]
then
	printf 'No command is specified!\n' 1>&2
	exit 1
fi
case "$1" in
	create) shift ; create_test "$@" ;;
	delete) shift ; delete_test "$@" ;;
	*) printf 'Unknown command "%s"!\n' "$1" 1>&2 ; exit 1 ;;
esac
