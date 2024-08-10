#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_stash_structure() { # stash_num expected_to_have_untracked
	if ! git rev-parse --quiet --verify "stash@{$1}^{commit}" 1>/dev/null
	then
		printf '"%s" is not a valid commit!\n' "stash@{$1}" 1>&3
		return 1
	fi
	if [ "$2" = y ]
	then
		expected_value=3
	else
		expected_value=2
	fi
	value_for_assert="$(git rev-list --no-walk --count "stash@{$1}^@")"
	if [ "$value_for_assert" -ne "$expected_value" ]
	then
		printf '"%s" should have %i parents but it has %i!\n' "stash@{$1}" "$expected_value" "$value_for_assert" 1>&3
		return 1
	fi
	value_for_assert="$(git rev-list --no-walk --count "stash@{$1}^2^@")"
	if [ "$value_for_assert" -ne 1 ]
	then
		printf '"%s" should have 1 parent but it has %i!\n' "stash@{$1}^2" "$value_for_assert" 1>&3
		return 1
	fi
	if [ "$2" = y ]
	then
		value_for_assert="$(git rev-list --no-walk --count "stash@{$1}^3^@")"
		if [ "$value_for_assert" -ne 0 ]
		then
			printf '"%s" should have 0 parents but it has %i!\n' "stash@{$1}^2" "$value_for_assert" 1>&3
			return 1
		fi
	fi
	if [ "$(git rev-parse "stash@{$1}^1")" != "$(git rev-parse "stash@{$1}^2^1")" ]
	then
		printf '"%s" and "%s" are different commits!\n' "stash@{$1}^1" "stash@{$1}^2^1" 1>&3
		return 1
	fi
	unset expected_value
	unset value_for_assert
}

_make_parent_summary_regex() { # stash_num
	_sanitize_for_bre "$(git rev-list --no-commit-header --format='%h %s' --max-count=1 "stash@{$1}~")"
}

assert_stash_top_message() { # stash_num expected_branch_name expeted_stash_name
	value_for_assert="$(git rev-list --format=%B --max-count=1 --no-commit-header "stash@{$1}")"
	if [ -z "$3" ]
	then
		expected_value_regex="WIP on $(_make_stash_name_regex "$2"): $(_make_parent_summary_regex "$1")"
	else
		expected_value_regex="On $(_make_stash_name_regex "$2"): $(_sanitize_for_bre "$3")$"
	fi
	if printf '%s\n' "$value_for_assert" | grep -xvq "$expected_value_regex"
	then
		printf 'The message on the top stash commit is different than expected!\n' 1>&3
		printf '(It'\''s "%s".)\n' "$value_for_assert" 1>&3
		printf '(It should match "%s".)\n' "$expected_value_regex" 1>&3
		return 1
	fi
	unset expected_value_regex
	unset value_for_assert
}

assert_stash_index_message() { # stash_num expected_branch_name
	value_for_assert="$(git rev-list --format=%B --max-count=1 --no-commit-header "stash@{$1}^2")"
	expected_value_regex="index on $(_make_stash_name_regex "$2"): $(_make_parent_summary_regex "$1")"
	if printf '%s\n' "$value_for_assert" | grep -xvq "$expected_value_regex"
	then
		printf 'The message on the stash commit with index is different than expected!\n' 1>&3
		printf '(It'\''s "%s".)\n' "$value_for_assert" 1>&3
		printf '(It should match "%s".)\n' "$expected_value_regex" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_stash_untracked_message() { # stash_num expected_branch_name
	value_for_assert="$(git rev-list --format=%B --max-count=1 --no-commit-header "stash@{$1}^3")"
	expected_value_regex="untracked files on $(_make_stash_name_regex "$2"): $(_make_parent_summary_regex "$1")"
	if printf '%s\n' "$value_for_assert" | grep -xvq "$expected_value_regex"
	then
		printf 'The message on the stash commit with untracked files is different than expected!\n' 1>&3
		printf '(It'\''s "%s".)\n' "$value_for_assert" 1>&3
		printf '(It should match "%s".)\n' "$expected_value_regex" 1>&3
		return 1
	fi
	unset value_for_assert
}

assert_stash_messages() { # stash_num expected_branch_name expect_untracked expeted_stash_name
	assert_stash_top_message "$1" "$2" "$4"
	assert_stash_index_message "$1" "$2"
	if [ "$3" = y ]
	then
		assert_stash_untracked_message "$1" "$2"
	fi
}

assert_stash_commit_files() { # commit expected_files
	value_for_assert="$(git ls-tree --name-only --full-tree -r "$1")"
	expected_value="$(printf '%s\n' "$2" | awk '{print $1}')"
	if [ "$value_for_assert" != "$expected_value" ]
	then
		printf 'Expected all files in "%s" to be "%s" but they are "%s"!\n' "$1" "$expected_value" "$value_for_assert" 1>&3
		return 1
	fi
	unset value_for_assert
	unset expected_value
}

assert_stash_commit_files_with_content() { # commit expected_files
	assert_stash_commit_files "$@"
	printf '%s\n' "$2" \
	| while read -r line
	do
		value_for_assert="$(git show "$1:$(printf '%s' "$line" | awk '{print $1}')")"
		expected_value="$(printf '%s' "$line" | awk '{print $2}')"
		if [ "$value_for_assert" != "$expected_value" ]
		then
			printf 'Expected content of file "%s" in "%s" to be "%s" but it is "%s"!\n' "$(printf '%s' "$line" | awk '{print $1}')" "$1" "$expected_value" "$value_for_assert" 1>&3
			return 1
		fi
	done
	unset value_for_assert
	unset expected_value
}

assert_stash_files() { # stash_num expect_untracked expected_files
	expected_files="$(printf '%s\n' "$3" | grep -v '^\s*$' | sed 's/^\(...\)\(.*\)$/\2\1/' | sort | sed 's/^\(.*\)\(...\)$/\2\1/')"
	assert_stash_commit_files_with_content "stash@{$1}" "$(
			printf '%s\n' "$expected_files" \
			| while IFS= read -r line
			do
				if printf '%s' "$line" | grep -vq '^?? '
				then
					printf '%s' "$line" | cut -c4- | awk '{print $1,$2}'
				fi
			done
		)"
	assert_stash_commit_files "stash@{$1}^1" "$(
			printf '%s\n' "$expected_files" \
			| while IFS= read -r line
			do
				if printf '%s' "$line" | grep -vq '^\(??\|A.\|.A\) '
				then
					printf '%s' "$line" | cut -c4- | awk '{print $1}'
				fi
			done
		)"
	assert_stash_commit_files_with_content "stash@{$1}^2" "$(
			printf '%s\n' "$expected_files" \
			| while IFS= read -r line
			do
				if printf '%s' "$line" | grep -q '^[ AM][^ ] '
				then
					printf '%s' "$line" | cut -c4- | awk '{print $1,$3}'
				elif printf '%s' "$line" | grep -q '^[ AM][ ] '
				then
					printf '%s' "$line" | cut -c4- | awk '{print $1,$2}'
				fi
			done
		)"
	if [ "$2" = n ]
	then
		unset expected_files
		return 0
	fi
	assert_stash_commit_files_with_content "stash@{$1}^3" "$(
			printf '%s\n' "$expected_files" \
			| while IFS= read -r line
			do
				if printf '%s' "$line" | grep -q '^?? '
				then
					printf '%s' "$line" | cut -c4- | awk '{print $1,$2}'
				fi
			done
		)"
	unset expected_files
}

assert_stash() { # stash_num expected_branch_name expected_stash_name expected_files
	if printf '%s\n' "$4" | grep -q '^?? '
	then
		expect_untracked=y
	else
		expect_untracked=n
	fi
	assert_stash_structure "$1" "$expect_untracked"
	assert_stash_messages "$1" "$2" "$expect_untracked" "$3"
	assert_stash_files "$1" "$expect_untracked" "$4"
	unset expect_untracked
}
