#!/usr/bin/env sh

printf 'This script is not supposed to be run.\n'
printf 'If you want to use it IN a test, source it with the command:\n. ../commons.sh 1>/dev/null\n'
if [ -t 1 ] ; then exit 1 ; fi

if [ "$WAS_IT_CALLED_FROM_RUN_SH" != 'indeed' ]
then
	printf 'It looks like you'\''re trying to run a test without using the script "tests/run.sh".\n' 1>&2
	printf 'Don'\''t! It would break everything.\n' 1>&2
	exit 1
fi

# Note that this script sets terminal to exit upon encountering any error.
# Note that the arguments of these functions are not thoroughly validated. Familiarize yourself with them before trying to use them.
# Note that streams 4..8 are used by scripts (here and in `run.sh`) and they shouldn't be touched. (Stream is used to print assertion errors and you can write to it.)

set -e

# Setting up the test repository
export GIT_CONFIG_SYSTEM=/dev/null
export GIT_CONFIG_GLOBAL=/dev/null
git init --initial-branch=master
git config --local user.email 'test@localhost'
git config --local user.name 'test'
git commit --allow-empty -m 'Initial commit'
printf 'ignored\n' >>.git/info/exclude
printf 'ignored\n' >ignored

capture_outputs() { # command [arguments...]
	stdout_file="$(mktemp)"
	stderr_file="$(mktemp)"
	exec 7>&1
	error_code="$(
		set +e
		{
			{
				{
					"$@" 8>&2 2>&1 1>&8 8>&-
					printf '%i\n' $? 1>&7
				} | tee "$stderr_file"
			} 8>&2 2>&1 1>&8 8>&- | tee "$stdout_file"
		} 8>&7 7>&1 1>&8 8>&-
	)"
	exec 7>&-
	#shellcheck disable=SC2034
	stdout="$(cat "$stdout_file")"
	rm "$stdout_file"
	unset stdout_file
	#shellcheck disable=SC2034
	stderr="$(cat "$stderr_file")"
	rm "$stderr_file"
	unset stderr_file
	return "$error_code"
}

command_to_string() { # command [arguments...]
	if [ "$1" = 'capture_outputs' ]
	then
		shift
	fi
	printf '"%s"' "$*"
}

assert_exit_code() { # expected_code command [arguments...]
	expected_exit_code_for_assert="$1"
	shift
	exit_code_for_assert=0
	"$@" || exit_code_for_assert=$?
	if [ "$exit_code_for_assert" -ne "$expected_exit_code_for_assert" ]
	then
		printf 'Command %s returned exit code %i but %i was expected!\n' "$(command_to_string "$@")" $exit_code_for_assert "$expected_exit_code_for_assert" 1>&3
		return 1
	fi
	unset expected_exit_code_for_assert
	unset exit_code_for_assert
}

assert_conflict_message() { # git command subcommand [arguments...]
	if [ "$(printf '%s' "$stderr" | tail -n4)" != "
hint: Disregard all hints above about using \"git rebase\".
hint: Use \"$1 $2 $3 --continue\" after fixing conflicts.
hint: To abort and get back to the state before \"$1 $2 $3\", run \"$1 $2 $3 --abort\"." ]
	then
		printf 'Command %s didn'\''t print the correct conflict message!\n' "$(command_to_string "$@")" 1>&3
		return 1
	fi
}

assert_all_files() { # expected
	value_for_assert="$(find . -type f ! -path './.git/*' | cut -c3- | sort | head -c -1 | tr '\n' '|')"
	if [ "$value_for_assert" != "$1" ]
	then
		printf 'Expected all files outside of ".git" to be "%s" but they are "%s"!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_tracked_files() { # expected
	value_for_assert="$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')"
	if [ "$value_for_assert" != "$1" ]
	then
		printf 'Expected tracked files to be "%s" but they are "%s"!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_status() { # expected
	value_for_assert="$(git status --porcelain | head -c -1 | tr '\n' '|')"
	if [ "$value_for_assert" != "$1" ]
	then
		printf 'Expected repository status to be "%s" but it is "%s"!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_file_contents() { # file expected_current [expected_staged]
	value_for_assert="$(cat "$1")"
	if printf '%s' "$2" | grep -q '|'
	then
		ours_expected_contents="$(printf '%s' "$2" | cut -d'|' -f1)"
		theirs_expected_contents="$(printf '%s' "$2" | cut -d'|' -f2)"
		if [ "$(printf '%s\n' "$value_for_assert" | grep -c '^=\{7\}')" -ne 1 ]
		then
			printf 'Expected file "%s" contain exactly 1 conflict!\n' "$1" 1>&3
			return 1
		fi
		if ! printf '%s\n' "$value_for_assert" | head -n1 | grep -q '^<\{7\} HEAD' || ! printf '%s\n' "$value_for_assert" | tail -n1 | grep -q '^>\{7\} '
		then
			printf 'Expected file "%s" to be comprised entirely from a conflict!\n' "$1" 1>&3
			return 1
		fi
		sub_value_for_assert="$(printf '%s\n' "$value_for_assert" | tail -n+2 | sed '/^=\{7\}/ q' | head -n-1)"
		if [ "$sub_value_for_assert" != "$ours_expected_contents" ]
		then
			printf 'Expected the HEAD side of the conflict in "%s" to be "%s" but it is "%s"!\n' "$1" "$ours_expected_contents" "$sub_value_for_assert" 1>&3
			return 1
		fi
		sub_value_for_assert="$(printf '%s\n' "$value_for_assert" | head -n-1 | sed -n '/^=\{7\}/,$ p ' | tail -n+2)"
		if [ "$sub_value_for_assert" != "$theirs_expected_contents" ]
		then
			printf 'Expected the stash side of the conflict in "%s" to be "%s" but it is "%s"!\n' "$1" "$theirs_expected_contents" "$sub_value_for_assert" 1>&3
			return 1
		fi
		unset sub_value_for_assert
		unset ours_expected_contents
		unset theirs_expected_contents
	else
		if [ "$value_for_assert" != "$2" ]
		then
			printf 'Expected content of file "%s" to be "%s" but it is "%s"!\n' "$1" "$2" "$value_for_assert" 1>&3
			return 1
		fi
		if [ $# -eq 3 ]
		then
			value_for_assert="$(git show ":$1")"
			if [ "$value_for_assert" != "$3" ]
			then
				printf 'Expected staged content of file "%s" to be "%s" but it is "%s"!\n' "$1" "$3" "$value_for_assert" 1>&3
				return 1
			fi
		fi
	fi
	unset value_for_assert
}

assert_files() { # expected_files (see one of the tests as an example)
	expected_files="$(printf '%s\n' "$1" | grep -v '^\s*$' | sed 's/^\(...\)\(.*\)$/\2\1/' | sort | sed 's/^\(.*\)\(...\)$/\2\1/')"
	assert_all_files "$(printf '%s\n' "$expected_files" | sed 's/^...\(\S\+\)\(\s.*\)\?$/\1/' | head -c-1 | tr '\n' '|')"
	assert_tracked_files "$(printf '%s\n' "$expected_files" | grep -v '^\(!!\|??\|^A[^A]\|^ A\|^D.\) ' | sed 's/^...\(\S\+\)\(\s.*\)\?$/\1/' | head -c-1 | tr '\n' '|')"
	assert_status "$({ printf '%s\n' "$expected_files" | grep -v '^\(??\) ' ; printf '%s\n' "$expected_files" | grep '^\(??\) ' ; } | grep -v '^\(  \|!!\) ' | sed 's/^\(...\S\+\)\(\s.*\)\?$/\1/' | head -c-1 | tr '\n' '|')"
	printf '%s\n' "$expected_files" \
	| while IFS= read -r line
	do
		stripped_line="$(printf '%s' "$line" | cut -c4-)"
		if printf '%s' "$line" | grep -q '^\(UU\|!!\|??\|.A\|D.\|. \) '
		then
			if [ "$(printf '%s' "$stripped_line" | awk '{printf NF}')" -ne 2 ]
			then
				printf 'Error in test: the file "%s" should have 1 version of content to check!\n' "$(printf '%s' "$stripped_line" | awk '{printf $1}')" 1>&3
				return 1
			fi
			if printf '%s' "$line" | grep -q '^\(. \) '
			then
				assert_file_contents \
					"$(printf '%s' "$stripped_line" | awk '{printf $1}')" \
					"$(printf '%s' "$stripped_line" | awk '{printf $2}')" \
					"$(printf '%s' "$stripped_line" | awk '{printf $2}')"
			else
				assert_file_contents \
					"$(printf '%s' "$stripped_line" | awk '{printf $1}')" \
					"$(printf '%s' "$stripped_line" | awk '{printf $2}')"
			fi
		else
			if [ "$(printf '%s' "$stripped_line" | awk '{printf NF}')" -ne 3 ]
			then
				printf 'Error in test: the file "%s" should have 2 versions of content to check!\n' "$(printf '%s' "$stripped_line" | awk '{printf $1}')" 1>&3
				return 1
			fi
			assert_file_contents \
				"$(printf '%s' "$stripped_line" | awk '{printf $1}')" \
				"$(printf '%s' "$stripped_line" | awk '{printf $2}')" \
				"$(printf '%s' "$stripped_line" | awk '{printf $3}')"
		fi
	done
}

assert_stash_count() { # expected
	value_for_assert="$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)"
	if [ "$value_for_assert" -ne "$1" ]
	then
		printf 'Expected number of stashes to be %i but it is %i!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_log_length() { # expected
	value_for_assert="$(git rev-list --count HEAD)"
	if [ "$value_for_assert" -ne "$1" ]
	then
		printf 'Expected lenght of HEAD'\''s history to be %i but it is %i!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_branch_count() { # expected
	value_for_assert="$(git for-each-ref refs/heads --format='x' | wc -l)"
	if [ "$value_for_assert" -ne "$1" ]
	then
		printf 'Expected number of branches to be %i but it is %i!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_head_hash() { # expected
	value_for_assert="$(git rev-parse HEAD)"
	if [ "$value_for_assert" != "$1" ]
	then
		printf 'Expected HEAD to be at %s but it is at %s!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_stash_hash() { # stash_num expected
	value_for_assert="$(git rev-parse "stash@{$1}")"
	if [ "$value_for_assert" != "$2" ]
	then
		printf 'Expected stash entry #%i to be %s but it is %s!\n' "$1" "$2" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_head_name() { # expected
	if printf '%s' "$1" | grep -q '^~'
	then
		set -- "$(printf '%s' "$1" | cut -c2-)"
		if git rev-parse HEAD 1>/dev/null 2>&1
		then
			printf 'Expected HEAD to be an orphan!\n' 1>&3
			return 1
		fi
		value_for_assert="$(git branch --show-current)"
	else
		if ! git rev-parse HEAD 1>/dev/null 2>&1
		then
			printf 'Didn'\''t expect HEAD to be an orphan!\n' 1>&3
			return 1
		fi
		value_for_assert="$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)"
	fi
	if [ "$value_for_assert" != "$1" ]
	then
		printf 'Expected the name of HEAD branch be "%s" but it is "%s"!\n' "$1" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
}

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

assert_rebase() { # expected_in_progress
	if [ "$1" = y ]
	then
		if [ -e ".git/rebase-apply" ]
		then
			printf 'Expected rebase to be in the merge mode!\n' 1>&3
			return 1
		fi
		if [ ! -e ".git/rebase-merge" ]
		then
			printf 'Expected rebase to be in progress!\n' 1>&3
			return 1
		fi
	else
		if [ -e ".git/rebase-apply" ] || [ -e ".git/rebase-merge" ]
		then
			printf 'Expected rebase to NOT be in progress!\n' 1>&3
			return 1
		fi
	fi
}
