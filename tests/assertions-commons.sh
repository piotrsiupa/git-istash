#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_exit_code() { # expected_code command [arguments...]
	expected_exit_code_for_assert="$1"
	shift
	exit_code_for_assert=0
	"$@" || exit_code_for_assert=$?
	test "$exit_code_for_assert" -eq "$expected_exit_code_for_assert" ||
		fail 'Command %s returned exit code %i but %i was expected!\n' "$(command_to_string "$@")" $exit_code_for_assert "$expected_exit_code_for_assert"
	unset expected_exit_code_for_assert
	unset exit_code_for_assert
}

assert_conflict_message() { # git command subcommand [arguments...]
	#shellcheck disable=SC2154
	test "$(printf '%s' "$stderr" | tail -n4)" = "
hint: Disregard all hints above about using \"git rebase\".
hint: Use \"$1 $2 $3 --continue\" after fixing conflicts.
hint: To abort and get back to the state before \"$1 $2 $3\", run \"$1 $2 $3 --abort\"." ||
		fail 'Command %s didn'\''t print the correct conflict message!\n' "$(command_to_string "$@")"
}

assert_all_files() { # expected
	value_for_assert="$(find . -type f ! -path './.git/*' | cut -c3- | sort | head -c -1 | tr '\n' '|')"
	test "$value_for_assert" = "$1" ||
		fail 'Expected all files outside of ".git" to be "%s" but they are "%s"!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_tracked_files() { # expected
	value_for_assert="$(git ls-tree -r --name-only HEAD | sort | head -c -1 | tr '\n' '|')"
	test "$value_for_assert" = "$1" ||
		fail 'Expected tracked files to be "%s" but they are "%s"!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_status() { # expected
	value_for_assert="$(git status --porcelain | head -c -1 | tr '\n' '|')"
	test "$value_for_assert" = "$1" ||
		fail 'Expected repository status to be "%s" but it is "%s"!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_file_contents() { # file expected_current [expected_staged]
	if [ -n "$2" ]
	then
		value_for_assert="$(cat "$1")"
	else
		value_for_assert=''
	fi
	if printf '%s' "$2" | grep -qE '\|'
	then
		ours_expected_contents="$(printf '%s' "$2" | cut -d'|' -f1)"
		theirs_expected_contents="$(printf '%s' "$2" | cut -d'|' -f2)"
		test "$(printf '%s\n' "$value_for_assert" | grep -cE '^={7}')" -eq 1 ||
			fail 'Expected file "%s" contain exactly 1 conflict!\n' "$1"
		#shellcheck disable=SC2015
		printf '%s\n' "$value_for_assert" | head -n1 | grep -qE '^<{7} HEAD' \
		&& printf '%s\n' "$value_for_assert" | tail -n1 | grep -qE '^>{7} ' ||
			fail 'Expected file "%s" to be comprised entirely from a conflict!\n' "$1"
		sub_value_for_assert="$(printf '%s\n' "$value_for_assert" | tail -n+2 | sed -E '/^={7}/ q' | head -n-1)"
		test "$sub_value_for_assert" = "$ours_expected_contents" ||
			fail 'Expected the HEAD side of the conflict in "%s" to be "%s" but it is "%s"!\n' "$1" "$ours_expected_contents" "$sub_value_for_assert"
		sub_value_for_assert="$(printf '%s\n' "$value_for_assert" | head -n-1 | sed -nE '/^={7}/,$ p ' | tail -n+2)"
		test "$sub_value_for_assert" = "$theirs_expected_contents" ||
			fail 'Expected the stash side of the conflict in "%s" to be "%s" but it is "%s"!\n' "$1" "$theirs_expected_contents" "$sub_value_for_assert"
		unset sub_value_for_assert
		unset ours_expected_contents
		unset theirs_expected_contents
	else
		test "$value_for_assert" = "$2" ||
			fail 'Expected content of file "%s" to be "%s" but it is "%s"!\n' "$1" "$2" "$value_for_assert"
		if [ $# -eq 3 ]
		then
			value_for_assert="$(git show ":$1")"
			test "$value_for_assert" = "$3" ||
				fail 'Expected staged content of file "%s" to be "%s" but it is "%s"!\n' "$1" "$3" "$value_for_assert"
		fi
	fi
	unset value_for_assert
}

assert_files() { # expected_files (see one of the tests as an example)
	expected_files="$(printf '%s\n' "$1" | sed -E 's/^\t+//' | grep -vE '^\s*$' | sed -E 's/^(...)(.*)$/\2\1/' | sort | sed -E 's/^(.*)(...)$/\2\1/')"
	assert_all_files "$(printf '%s\n' "$expected_files" | grep -vE '^(D |.D) ' | sed -E 's/^...(\S+)(\s.*)?$/\1/' | head -c-1 | tr '\n' '|')"
	assert_tracked_files "$(printf '%s\n' "$expected_files" | grep -vE '^(!!|\?\?|A[^A]| A|DU) ' | sed -E 's/^...(\S+)(\s.*)?$/\1/' | head -c-1 | tr '\n' '|')"
	assert_status "$({ printf '%s\n' "$expected_files" | grep -vE '^(\?\?) ' ; printf '%s\n' "$expected_files" | grep -E '^(\?\?) ' ; } | grep -vE '^(  |!!) ' | sed -E 's/^(...\S+)(\s.*)?$/\1/' | head -c-1 | tr '\n' '|')"
	printf '%s\n' "$expected_files" \
	| while IFS= read -r line
	do
		stripped_line="$(printf '%s' "$line" | cut -c4-)"
		if printf '%s' "$line" | grep -qE '^(D ) '
		then
			test "$(printf '%s' "$stripped_line" | awk '{printf NF}')" -eq 1 ||
				fail 'Error in test: the file "%s" should have 0 versions of content to check!\n' "$(printf '%s' "$stripped_line" | awk '{printf $1}')"
		elif printf '%s' "$line" | grep -qE '^([UD]U|!!|\?\?|.[ AD]) '
		then
			test "$(printf '%s' "$stripped_line" | awk '{printf NF}')" -eq 2 ||
				fail 'Error in test: the file "%s" should have 1 version of content to check!\n' "$(printf '%s' "$stripped_line" | awk '{printf $1}')"
			if printf '%s' "$line" | grep -qE '^(. ) '
			then
				assert_file_contents \
					"$(printf '%s' "$stripped_line" | awk '{printf $1}')" \
					"$(printf '%s' "$stripped_line" | awk '{printf $2}')" \
					"$(printf '%s' "$stripped_line" | awk '{printf $2}')"
			elif printf '%s' "$line" | grep -qE '^(.D) '
			then
				assert_file_contents \
					"$(printf '%s' "$stripped_line" | awk '{printf $1}')" \
					'' \
					"$(printf '%s' "$stripped_line" | awk '{printf $2}')"
			else
				assert_file_contents \
					"$(printf '%s' "$stripped_line" | awk '{printf $1}')" \
					"$(printf '%s' "$stripped_line" | awk '{printf $2}')"
			fi
		else
			test "$(printf '%s' "$stripped_line" | awk '{printf NF}')" -eq 3 ||
				fail 'Error in test: the file "%s" should have 2 versions of content to check!\n' "$(printf '%s' "$stripped_line" | awk '{printf $1}')"
			assert_file_contents \
				"$(printf '%s' "$stripped_line" | awk '{printf $1}')" \
				"$(printf '%s' "$stripped_line" | awk '{printf $2}')" \
				"$(printf '%s' "$stripped_line" | awk '{printf $3}')"
		fi
	done
}

assert_stash_count() { # expected
	value_for_assert="$(git rev-list --walk-reflogs --count --ignore-missing refs/stash)"
	test "$value_for_assert" -eq "$1" ||
		fail 'Expected number of stashes to be %i but it is %i!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_log_length() { # expected
	if [ "$1" -ne 0 ]
	then
		value_for_assert="$(git rev-list --count 'HEAD')"
		test "$value_for_assert" -eq "$1" ||
			fail 'Expected lenght of HEAD'\''s history to be %i but it is %i!\n' "$1" "$value_for_assert"
		unset value_for_assert
	else
		! git rev-parse --verify HEAD 2>/dev/null ||
		{
			value_for_assert="$(git rev-list --count 'HEAD')"
			fail 'Expected lenght of HEAD'\''s history to be 0 but it is %i!\n' "$value_for_assert"
		}
	fi
}

assert_branch_count() { # expected
	value_for_assert="$(git for-each-ref refs/heads --format='x' | wc -l)"
	test "$value_for_assert" -eq "$1" ||
		fail 'Expected number of branches to be %i but it is %i!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_head_hash() { # expected
	value_for_assert="$(get_head_hash)"
	test "$value_for_assert" = "$1" ||
		fail 'Expected HEAD to be at %s but it is at %s!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_stash_hash() { # stash_num expected
	value_for_assert="$(git rev-parse "stash@{$1}")"
	test "$value_for_assert" = "$2" ||
		fail 'Expected stash entry #%i to be %s but it is %s!\n' "$1" "$2" "$value_for_assert"
	unset value_for_assert
}

assert_head_name() { # expected
	if printf '%s' "$1" | grep -qE '^~'
	then
		set -- "$(printf '%s' "$1" | cut -c2-)"
		! git rev-parse HEAD 1>/dev/null 2>&1 ||
			fail 'Expected HEAD to be an orphan!\n'
		value_for_assert="$(git branch --show-current)"
	else
		git rev-parse HEAD 1>/dev/null 2>&1 ||
			fail 'Didn'\''t expect HEAD to be an orphan!\n'
		value_for_assert="$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)"
	fi
	test "$value_for_assert" = "$1" ||
		if [ "$value_for_assert" = 'HEAD' ]
		then
			fail 'Expected the HEAD branch be named "%s" but it is a detached branch!\n' "$1"
		elif [ "$1" = 'HEAD' ]
		then
			fail 'Expected the HEAD branch be detached but it is named "%s"!\n' "$value_for_assert"
		else
			fail 'Expected the name of the HEAD branch be "%s" but it is "%s"!\n' "$1" "$value_for_assert"
		fi
	unset value_for_assert
}

assert_rebase() { # expected_in_progress
	if [ "$1" = y ]
	then
		test ! -e ".git/rebase-apply" ||
			fail 'Expected rebase to be in the merge mode!\n'
		test -e ".git/rebase-merge" ||
			fail 'Expected rebase to be in progress!\n'
	else
		#shellcheck disable=SC2015
		test ! -e ".git/rebase-apply" && test ! -e ".git/rebase-merge" ||
			fail 'Expected rebase to NOT be in progress!\n'
	fi
}

assert_files_H() { # expected_files [expected_files_for_orphan]
	if ! IS_HEAD_ORPHAN || [ $# -lt 2 ]
	then
		assert_files "$1"
	else
		assert_files "$2"
	fi
}
assert_log_length_H() { # expected_for_not_orphan
	if IS_HEAD_ORPHAN
	then
		set -- 0
	fi
	assert_log_length "$1"
}
assert_branch_count_H() { # expected_for_not_orphan
	if IS_HEAD_ORPHAN
	then
		set -- $(($1 + 1))
	fi
	assert_branch_count "$1"
}
assert_head_hash_H() { # expected_for_not_orphan
	value_for_assert="$(get_head_hash_H)"
	test "$value_for_assert" = "$1" ||
		fail 'Expected HEAD to be at %s but it is at %s!\n' "$1" "$value_for_assert"
	unset value_for_assert
}
assert_head_name_H() {
	case "$HEAD_TYPE" in
		'BRANCH') assert_head_name 'master' ;;
		'DETACH') assert_head_name 'HEAD' ;;
		'ORPHAN') assert_head_name '~ooo' ;;
		*) fail 'Unknown HEAD type "%s"!' "$HEAD_TYPE" ;;
	esac
}
