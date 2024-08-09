#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_data_file() { # is_expected data_point_name
	file_path_for_assert=".git/ISTASH_$2"
	if [ "$1" = n ]
	then
		if [ -e "$file_path_for_assert" ]
		then
			printf 'Expected the file "%s" to NOT be present!\n' "$file_path_for_assert" 1>&3
			return 1
		fi
	else
		if [ ! -e "$file_path_for_assert" ]
		then
			printf 'Expected the file "%s" to be present!\n' "$file_path_for_assert" 1>&3
			return 1
		fi
		if [ ! -f "$file_path_for_assert" ]
		then
			printf 'Expected "%s" to be a file!\n' "$file_path_for_assert" 1>&3
			return 1
		fi
		if [ "$(wc -l "$file_path_for_assert" | awk '{print $1}')" -ne 1 ]
		then
			printf 'Expected the file "%s" to have 1 line!\n' "$file_path_for_assert" 1>&3
			return 1
		fi
	fi
	unset file_path_for_assert
}

assert_data_files() { # expected_state
	case "$1" in
		none)
			assert_data_file n 'TARGET'
			assert_data_file n 'STASH'
			;;
		apply)
			assert_data_file y 'TARGET'
			assert_data_file n 'STASH'
			;;
		pop)
			assert_data_file y 'TARGET'
			assert_data_file y 'STASH'
			;;
		*)
			return 1
			;;
	esac
}
