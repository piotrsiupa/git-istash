#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


assert_stash_structure() { # stash_num expected_to_have_untracked
	git rev-parse --quiet --verify "stash@{$1}^{commit}" 1>/dev/null ||
		fail '"%s" is not a valid commit!\n' "stash@{$1}"
	if [ "$2" = y ]
	then
		expected_value=3
	else
		expected_value=2
	fi
	value_for_assert="$(git rev-list --no-walk --count "stash@{$1}^@")"
	test "$value_for_assert" -eq "$expected_value" ||
		fail '"%s" should have %i parents but it has %i!\n' "stash@{$1}" "$expected_value" "$value_for_assert"
	value_for_assert="$(git rev-list --no-walk --count "stash@{$1}^2^@")"
	test "$value_for_assert" -eq 1 ||
		fail '"%s" should have 1 parent but it has %i!\n' "stash@{$1}^2" "$value_for_assert"
	if [ "$2" = y ]
	then
		value_for_assert="$(git rev-list --no-walk --count "stash@{$1}^3^@")"
		test "$value_for_assert" -eq 0 ||
			fail '"%s" should have 0 parents but it has %i!\n' "stash@{$1}^2" "$value_for_assert"
	fi
	test "$(git rev-parse "stash@{$1}^1")" = "$(git rev-parse "stash@{$1}^2^1")" ||
		fail '"%s" and "%s" are different commits!\n' "stash@{$1}^1" "stash@{$1}^2^1"
	unset expected_value
	unset value_for_assert
}

make_parent_summary_regex() { # stash_num
	sanitize_for_ere "$(git rev-list --no-commit-header --format='%h %s' --max-count=1 "stash@{$1}~")"
}

assert_stash_top_message() { # stash_num expected_branch_name expeted_stash_name
	value_for_assert="$(git rev-list --format=%B --max-count=1 --no-commit-header "stash@{$1}")"
	if [ -z "$3" ]
	then
		expected_value_regex="WIP on $(make_stash_name_regex "$2"): $(make_parent_summary_regex "$1")"
	else
		expected_value_regex="On $(make_stash_name_regex "$2"): $(sanitize_for_ere "$3")"
	fi
	! printf '%s\n' "$value_for_assert" | grep -xvqE "$expected_value_regex" ||
		fail 'The message on the top stash commit is different than expected!\n(It'\''s "%s".)\n(It should match "%s".)\n' "$value_for_assert" "$expected_value_regex"
	unset expected_value_regex
	unset value_for_assert
}

assert_stash_index_message() { # stash_num expected_branch_name
	value_for_assert="$(git rev-list --format=%B --max-count=1 --no-commit-header "stash@{$1}^2")"
	expected_value_regex="index on $(make_stash_name_regex "$2"): $(make_parent_summary_regex "$1")"
	! printf '%s\n' "$value_for_assert" | grep -xvqE "$expected_value_regex" ||
		fail 'The message on the stash commit with index is different than expected!\n(It'\''s "%s".)\n(It should match "%s".)\n' "$value_for_assert" "$expected_value_regex"
	unset expected_value_regex
	unset value_for_assert
}

assert_stash_untracked_message() { # stash_num expected_branch_name
	value_for_assert="$(git rev-list --format=%B --max-count=1 --no-commit-header "stash@{$1}^3")"
	expected_value_regex="untracked files on $(make_stash_name_regex "$2"): $(make_parent_summary_regex "$1")"
	! printf '%s\n' "$value_for_assert" | grep -xvqE "$expected_value_regex" ||
		fail 'The message on the stash commit with untracked files is different than expected!\n(It'\''s "%s".)\n(It should match "%s".)\n' "$value_for_assert" "$expected_value_regex"
	unset expected_value_regex
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

assert_stash_name() { # stash_num expected_branch_name expeted_stash_name
	value_for_assert="$(git stash list | grep -E '^stash@\{'"$1"'\}:')"
	if [ -z "$3" ]
	then
		expected_value_regex="stash@\\{$1\\}: WIP on $(make_stash_name_regex "$2"): $(make_parent_summary_regex "$1")"
	else
		expected_value_regex="stash@\\{$1\\}: On $(make_stash_name_regex "$2"): $(sanitize_for_ere "$3")"
	fi
	! printf '%s\n' "$value_for_assert" | grep -xvqE "$expected_value_regex" ||
		fail 'The stash message is different than expected!\n(It'\''s "%s".)\n(It should match "%s".)\n' "$value_for_assert" "$expected_value_regex"
	unset expected_value_regex
	unset value_for_assert
}

assert_stash_commit_files() { # commit expected_files
	value_for_assert="$(git ls-tree --name-only --full-tree -r -z "$1" | _convert_zero_separated_path_list | sort | _prepare_path_list_for_assertion)"
	expected_value="$(printf '%s\n' "$2" | awk '{print $1}' | _prepare_path_list_for_assertion)"
	test "$value_for_assert" = "$expected_value" ||
		fail 'Expected all files in "%s" to be:\n"%s"\nbut they are:\n"%s"!\n' "$1" "$expected_value" "$value_for_assert"
	unset value_for_assert
	unset expected_value
}

assert_stash_commit_files_with_content() { # commit expected_files
	assert_stash_commit_files "$@"
	if [ -z "$2" ]
	then
		return 0
	fi
	printf '%s\n' "$2" \
	| while read -r line
	do
		if [ -z "$line" ]
		then
			continue
		fi
		file_path_for_assertion="$(printf '%s' "$line" | awk '{print $1}')"
		value_for_assert="$(printf "%s:$file_path_for_assertion" "$1" | xargs -0 -- git show)"
		#shellcheck disable=SC2059
		expected_value="$(printf "$(printf '%s' "$line" | awk '{print $2}')")"
		test "$value_for_assert" = "$expected_value" ||
			fail 'Expected content of file "'"$file_path_for_assertion"'" in "%s" to be:\n"%s"\nbut it is:\n"%s"!\n' "$1" "$expected_value" "$value_for_assert"
		unset file_path_for_assertion
	done
	unset value_for_assert
	unset expected_value
}

assert_stash_files() { # stash_num expect_untracked expected_files
	expected_files="$(printf '%s\n' "$3" | sed -E 's/^\t+//' | grep -vE '^\s*$' | _sort_repository_status)"
	assert_stash_commit_files_with_content "stash@{$1}" "$(
			printf '%s\n' "$expected_files" \
			| grep -vE '^(\?\?|!!|D.|.D) ' \
			| cut -c4- | awk '{print $1,$2}'
		)"
	assert_stash_commit_files "stash@{$1}^1" "$(
			printf '%s\n' "$expected_files" \
			| grep -vE '^(\?\?|!!|A.|.A) ' \
			| cut -c4- | awk '{print $1}'
		)"
	assert_stash_commit_files_with_content "stash@{$1}^2" "$(
			printf '%s\n' "$expected_files" \
			| while IFS= read -r line
			do
				if printf '%s' "$line" | grep -qE '^([ AM][^ D]) '
				then
					printf '%s' "$line" | cut -c4- | awk '{print $1,$3}'
				elif printf '%s' "$line" | grep -qE '^([ AM][ D]) '
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
			| grep -E '^(\?\?|!!) ' \
			| cut -c4- | awk '{print $1,$2}'
		)"
	unset expected_files
}

assert_stash() { # stash_num expected_branch_name expected_stash_name expected_files
	if printf '%s\n' "$4" | sed -E 's/^\t+//' | grep -qE '^(\?\?|!!) '
	then
		expect_untracked=y
	else
		expect_untracked=n
	fi
	assert_stash_structure "$1" "$expect_untracked"
	assert_stash_messages "$1" "$2" "$expect_untracked" "$3"
	assert_stash_name "$1" "$2" "$3"
	assert_stash_files "$1" "$expect_untracked" "$4"
	unset expect_untracked
}
assert_stash_untracked() { # stash_num expected_branch_name expected_stash_name expected_files
	assert_stash_structure "$1" y
	assert_stash_messages "$1" "$2" y "$3"
	assert_stash_files "$1" y "$4"
}

assert_stash_base() { # stash_num expected_base
	git rev-parse --verify "stash@{$1}{commit}" 1>/dev/null ||
		fail 'There is no stash number %i!\n' "$1"
	if [ "$(printf '%s' "$2" | cut -c1)" != '~' ]
	then
		value_for_assert="$(git rev-parse "stash@{$1}^1")"
		expected_value="$(git rev-parse "$2")" ||
			fail 'There is no commit "%s"!\n' "$2"
		test "$value_for_assert" = "$expected_value" ||
			if [ "$expected_value" = "$2" ]
			then
				fail 'Expected the base of the "stash@{%i}" to be "%s" but it is "%s"!\n' "$1" "$expected_value" "$value_for_assert"
			else
				fail 'Expected the base of the "stash@{%i}" to be "%s" ("%s") but it is "%s"!\n' "$1" "$2" "$expected_value" "$value_for_assert"
			fi
		unset value_for_assert
		unset expected_value
	else
		value_for_assert="$(git rev-list --no-walk --count "stash@{$1}^1^@")"
		test "$value_for_assert" -eq 0 ||
			fail '"%s" should have no parents but it has %i!\n' "stash@{$1}" "$value_for_assert"
		value_for_assert="$(git rev-list --format=%B --max-count=1 --no-commit-header "stash@{$1}^1")"
		expected_value_regex="Base commit for stash entry on an orphan branch \"$(sanitize_for_ere "$(printf '%s' "$2" | cut -c2-)")\""
		! printf '%s\n' "$value_for_assert" | grep -xvqE "$expected_value_regex" ||
			fail 'The message on the stash commit with untracked files is different than expected!\n(It'\''s "%s".)\n(It should match "%s".)\n' "$value_for_assert" "$expected_value_regex"
		unset expected_value_regex
		unset value_for_assert
	fi
}

assert_stash_H() { # stash_num expected_stash_name expected_files [expected_files_for_orphan]
	case "$HEAD_TYPE" in
		'BRANCH') assert_stash "$1" 'master' "$2" "$3" ;;
		'DETACH') assert_stash "$1" 'HEAD' "$2" "$3" ;;
		'ORPHAN') if [ $# -lt 4 ] ; then assert_stash "$1" '~ooo' "$2" "$3" ; else assert_stash "$1" '~ooo' "$2" "$4" ; fi ;;
		*) fail 'Unknown HEAD type "%s"!' "$HEAD_TYPE" ;;
	esac
}
assert_stash_untracked_H() { # stash_num expected_stash_name expected_files [expected_files_for_orphan]
	case "$HEAD_TYPE" in
		'BRANCH') assert_stash_untracked "$1" 'master' "$2" "$3" ;;
		'DETACH') assert_stash_untracked "$1" 'HEAD' "$2" "$3" ;;
		'ORPHAN') if [ $# -lt 4 ] ; then assert_stash_untracked "$1" '~ooo' "$2" "$3" ; else assert_stash_untracked "$1" '~ooo' "$2" "$4" ; fi ;;
		*) fail 'Unknown HEAD type "%s"!' "$HEAD_TYPE" ;;
	esac
}
assert_stash_base_H() { # stash_num expected_base_for_not_orphan
	if ! IS_HEAD_ORPHAN
	then
		assert_stash_base "$1" "$2"
	else
		assert_stash_base "$1" '~ooo'
	fi
}
