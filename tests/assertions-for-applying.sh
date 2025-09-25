#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


#shellcheck disable=SC2120
assert_conflict_message() { # istash_command
	expected_istash_command="git istash $1"
	expected_error_message="
hint: Disregard all hints above about using \"git rebase\".
hint: Use \"$expected_istash_command --continue\" after fixing conflicts.
hint: To abort and get back to the state before \"$expected_istash_command\", run \"$expected_istash_command --abort\"."
	#shellcheck disable=SC2154
	test "$(printf '%s' "$stderr" | tail -n4)" = "$expected_error_message" ||
		fail 'Command "%s" didn'\''t print the correct conflict message!\nActual:\n"%s"\nExpected last 4 lines:\n"%s"\n' "$last_command" "$stderr" "$expected_error_message"
	unset expected_error_message
	unset expected_istash_command
}

assert_data_file() { # is_expected data_point_name
	file_path_for_assert=".git/ISTASH_$2"
	if [ "$1" = n ]
	then
		test ! -e "$file_path_for_assert" ||
			fail 'Expected the file "%s" to NOT be present!\n' "$file_path_for_assert"
	else
		test -e "$file_path_for_assert" ||
			fail 'Expected the file "%s" to be present!\n' "$file_path_for_assert"
		test -f "$file_path_for_assert" ||
			fail 'Expected "%s" to be a file!\n' "$file_path_for_assert"
		test "$(wc -l "$file_path_for_assert" | awk '{print $1}')" -eq 1 ||
			fail 'Expected the file "%s" to have 1 line!\n' "$file_path_for_assert"
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

assert_stash_count_AO() { # expected
	case "$APPLY_OPERATION" in
		apply) assert_stash_count "$1" ;;
		pop) assert_stash_count $(($1 - 1)) ;;
	esac
}
