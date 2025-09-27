#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# It also captures the command stdout and stderr for "assert_output" (just because it would be too much boiler plate to call "capture_outputs" every time).
assert_exit_code() { # expected_code command [arguments...]
	expected_exit_code_for_assert="$1"
	shift
	capture_outputs "$@" && exit_code_for_assert=0 || exit_code_for_assert=$?
	#shellcheck disable=SC2154
	test "$exit_code_for_assert" -eq "$expected_exit_code_for_assert" ||
		fail 'Command "%s" returned exit code %i but %i was expected!\n' "$last_command" "$exit_code_for_assert" "$expected_exit_code_for_assert"
	unset expected_exit_code_for_assert
	unset exit_code_for_assert
}

_convert_zero_separated_path_list() {
	if command -v od 1>/dev/null 2>&1
	then
		#shellcheck disable=SC1003
		od -bvAn | tr ' ' '\\' | tr -d '\n'
	else
		hexdump -ve'"\\" /1 "%03o"'
	fi \
	| sed -E -e 's/\\015/\\\\r/g' -e 's/\\012/\\\\n/g' -e 's/\\011/\\\\t/g' -e 's/\\134/\\\\\\\\/g' \
		-e 's/\\(00[1-7]|0[1-3][0-7]|040|177|[2-3][0-7]{2})/\\\\\1/g' \
		-e 's/\\045/\\045\\045/g' \
	| xargs -r0 -- printf -- \
	| tr -d '\n' | tr '\0' '\n'
}

_prepare_path_list_for_assertion() { # [has_prefix]
	if [ "${1-n}" = y ]
	then
		sed -E -e 's/^\\040/ /g' -e 's/^(.)\\040/\1 /g' -e 's/^(..)\\040/\1 /g' \
			-e 's/^(...)(.*)$/\2 \1/' \
		| sort \
		| sed -E 's/^(.*) (...)$/\2\1/'
	else
		sort
	fi \
	| tr '\n' '|' \
	| sed -E 's/.$//'
}

assert_all_files() { # expected
	value_for_assert="$(find . -type f ! -path './.git/*' -print0 | _convert_zero_separated_path_list | cut -c3- | _prepare_path_list_for_assertion)"
	test "$value_for_assert" = "$1" ||
		fail 'Expected all files in the working directory to be:\n"%s"\nbut they are:\n"%s"!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_tracked_files() { # expected
	value_for_assert="$(git ls-tree -r --name-only -z HEAD | _convert_zero_separated_path_list | _prepare_path_list_for_assertion)"
	test "$value_for_assert" = "$1" ||
		fail 'Expected tracked files to be:\n"%s"\nbut they are:\n"%s"!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_status() { # expected
	value_for_assert="$(git status --porcelain -z --untracked-files=all --ignored --no-renames | _convert_zero_separated_path_list | _prepare_path_list_for_assertion y)"
	test "$value_for_assert" = "$1" ||
		fail 'Expected repository status to be:\n"%s"\nbut it is:\n"%s"!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_file_contents() { # file expected_current [expected_staged]
	if [ -n "$2" ]
	then
		#shellcheck disable=SC2059
		value_for_assert="$(printf -- "$1" | xargs -0 -- cat)"
	else
		value_for_assert=''
	fi
	if printf '%s' "$2" | grep -qE '\|'
	then
		ours_expected_contents="$(printf '%s' "$2" | cut -d'|' -f1)"
		theirs_expected_contents="$(printf '%s' "$2" | cut -d'|' -f2)"
		test "$(printf '%s\n' "$value_for_assert" | grep -cE '^={7}')" -eq 1 ||
			fail 'Expected file "'"$1"'" contain exactly 1 conflict!\n'
		#shellcheck disable=SC2015
		printf '%s\n' "$value_for_assert" | head -n1 | grep -qE '^<{7} HEAD' \
		&& printf '%s\n' "$value_for_assert" | tail -n1 | grep -qE '^>{7} ' ||
			fail 'Expected file "'"$1"'" to be comprised entirely from a conflict!\n'
		sub_value_for_assert="$(printf '%s\n' "$value_for_assert" | tail -n+2 | sed -E '/^={7}/ q' | head -n-1)"
		test "$sub_value_for_assert" = "$ours_expected_contents" ||
			fail 'Expected the HEAD side of the conflict in "'"$1"'" to be:\n"%s"\nbut it is:\n"%s"!\n' "$ours_expected_contents" "$sub_value_for_assert"
		sub_value_for_assert="$(printf '%s\n' "$value_for_assert" | head -n-1 | sed -nE '/^={7}/,$ p ' | tail -n+2)"
		test "$sub_value_for_assert" = "$theirs_expected_contents" ||
			fail 'Expected the stash side of the conflict in "'"$1"'" to be:\n"%s"\nbut it is:\n"%s"!\n' "$theirs_expected_contents" "$sub_value_for_assert"
		unset sub_value_for_assert
		unset ours_expected_contents
		unset theirs_expected_contents
	else
		#shellcheck disable=SC2059
		expected_contents="$(printf -- "$2")"
		test "$value_for_assert" = "$expected_contents" ||
			fail 'Expected content of file "'"$1"'" to be:\n"%s"\nbut it is:\n"%s"!\n' "$expected_contents" "$value_for_assert"
		if [ $# -eq 3 ]
		then
			#shellcheck disable=SC2059
			value_for_assert="$(printf -- ":$1" | xargs -0 -- git show)"
			#shellcheck disable=SC2059
			expected_contents="$(printf -- "$3")"
			test "$value_for_assert" = "$expected_contents" ||
				fail 'Expected staged content of file "'"$1"'" to be:\n"%s"\nbut it is:\n"%s"!\n' "$expected_contents" "$value_for_assert"
		fi
		unset expected_contents
	fi
	unset value_for_assert
}

assert_files() { # expected_files (see one of the tests as an example)
	expected_files="$(printf '%s\n' "$1" | sed -E -e 's/^\t+//' -e '/^\s*$/ d')"
	assert_all_files "$(printf '%s\n' "$expected_files" | grep -vE '^(D |[^U]D) ' | sed -E 's/^...(\S+)(\s.*)?$/\1/' | _prepare_path_list_for_assertion)"
	assert_tracked_files "$(printf '%s\n' "$expected_files" | grep -vE '^(!!|\?\?|A[^A]| A|DU) ' | sed -E 's/^...(\S+)(\s.*)?$/\1/' | _prepare_path_list_for_assertion)"
	assert_status "$(printf '%s\n' "$expected_files" | grep -vE '^(  ) ' | sed -E 's/^(...\S+)(\s.*)?$/\1/' | _prepare_path_list_for_assertion y)"
	printf '%s\n' "$expected_files" \
	| while IFS= read -r line
	do
		if [ -z "$line" ]
		then
			continue
		fi
		stripped_line="$(printf '%s' "$line" | cut -c4-)"
		if printf '%s' "$line" | grep -qE '^(D ) '
		then
			test "$(printf '%s' "$stripped_line" | awk '{printf NF}')" -eq 1 ||
				fail 'Error in test: the file "%s" should have 0 versions of content to check!\n' "$(printf '%s' "$stripped_line" | awk '{printf "%s", $1}')"
		elif printf '%s' "$line" | grep -qE '^([UD]U|!!|\?\?|.[ AD]) '
		then
			test "$(printf '%s' "$stripped_line" | awk '{printf NF}')" -eq 2 ||
				fail 'Error in test: the file "%s" should have 1 version of content to check!\n' "$(printf '%s' "$stripped_line" | awk '{printf "%s", $1}')"
			if printf '%s' "$line" | grep -qE '^(. ) '
			then
				assert_file_contents \
					"$(printf '%s' "$stripped_line" | awk '{printf "%s", $1}' | sed -E 's/<empty>//')" \
					"$(printf '%s' "$stripped_line" | awk '{printf "%s", $2}' | sed -E 's/<empty>//')" \
					"$(printf '%s' "$stripped_line" | awk '{printf "%s", $2}' | sed -E 's/<empty>//')"
			elif printf '%s' "$line" | grep -qE '^([^U]D) '
			then
				assert_file_contents \
					"$(printf '%s' "$stripped_line" | awk '{printf "%s", $1}' | sed -E 's/<empty>//')" \
					'' \
					"$(printf '%s' "$stripped_line" | awk '{printf "%s", $2}' | sed -E 's/<empty>//')"
			else
				assert_file_contents \
					"$(printf '%s' "$stripped_line" | awk '{printf "%s", $1}' | sed -E 's/<empty>//')" \
					"$(printf '%s' "$stripped_line" | awk '{printf "%s", $2}' | sed -E 's/<empty>//')"
			fi
		else
			test "$(printf '%s' "$stripped_line" | awk '{printf NF}')" -eq 3 ||
				fail 'Error in test: the file "%s" should have 2 versions of content to check!\n' "$(printf '%s' "$stripped_line" | awk '{printf "%s", $1}')"
			assert_file_contents \
				"$(printf '%s' "$stripped_line" | awk '{printf "%s", $1}' | sed -E 's/<empty>//')" \
				"$(printf '%s' "$stripped_line" | awk '{printf "%s", $2}' | sed -E 's/<empty>//')" \
				"$(printf '%s' "$stripped_line" | awk '{printf "%s", $3}' | sed -E 's/<empty>//')"
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

assert_head_sha() { # expected
	value_for_assert="$(get_head_sha)"
	test "$value_for_assert" = "$1" ||
		fail 'Expected HEAD to be at %s but it is at %s!\n' "$1" "$value_for_assert"
	unset value_for_assert
}

assert_stash_sha() { # stash_num expected
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

assert_branch_metadata() {
	expected_value='my-origin/my-branch'
	value_for_assert="$(git for-each-ref --format='%(upstream:short)' -- "refs/heads/$(git branch --show-current)")"
	test "$value_for_assert" = "$expected_value" ||
		fail 'Expected the upstream branch to be "%s" but it is "%s"!\n' "$expected_value" "$value_for_assert"
	unset expected_value
	unset value_for_assert
}

assert_files_HT() { # expected_files [expected_files_for_orphan]
	if ! IS_HEAD_ORPHAN || [ $# -lt 2 ]
	then
		assert_files "$1"
	else
		assert_files "$2"
	fi
}
assert_log_length_HT() { # expected_for_not_orphan
	if IS_HEAD_ORPHAN
	then
		set -- 0
	fi
	assert_log_length "$1"
}
assert_branch_count_HT() { # expected_for_not_orphan
	if IS_HEAD_ORPHAN
	then
		set -- $(($1 + 1))
	fi
	assert_branch_count "$1"
}
assert_head_sha_HT() { # expected_for_not_orphan
	if ! IS_HEAD_ORPHAN
	then
		value_for_assert="$(get_head_sha)"
		test "$value_for_assert" = "$1" ||
			fail 'Expected HEAD to be at %s but it is at %s!\n' "$1" "$value_for_assert"
		unset value_for_assert
	fi
}
assert_head_name_HT() {
	case "$HEAD_TYPE" in
		'BRANCH') assert_head_name 'master' ;;
		'DETACH') assert_head_name 'HEAD' ;;
		'ORPHAN') assert_head_name '~ooo' ;;
		*) fail 'Unknown HEAD type "%s"!' "$HEAD_TYPE" ;;
	esac
}
assert_branch_metadata_HT() {
	if IS_HEAD_BRANCH
	then
		assert_branch_metadata
	fi
}

assert_dotgit_contents() { # expected_file_names...
	expected_value="$(printf '%s\n' "$@" | sort)"
	value_for_assert="$(find .git -type f -name '*[Ii][Ss][Tt][Aa][Ss][Hh]*' | sed 's;^\.git/;;' | sort)"
	test "$value_for_assert" = "$expected_value" ||
		fail 'Unexpected files were left in the directory ".git":\n%s\nExpected:\n%s\n' "$(printf '%s' "$value_for_assert" | sed 's/^.*$/- "&"/')" "$(printf '%s' "$expected_value" | sed 's/^.*$/- "&"/')"
	unset expected_value
	unset value_for_assert
}
assert_dotgit_contents_for() { # operation [additional_expected_file_names...]
	operation_for_assert="$1"
	shift
	case "$operation_for_assert" in
		'apply') assert_dotgit_contents 'ISTASH_TARGET' 'ISTASH_WORKING-DIR' "$@" ;;
		'pop') assert_dotgit_contents 'ISTASH_TARGET' 'ISTASH_STASH' 'ISTASH_WORKING-DIR' "$@" ;;
		*) fail 'Unknown operation "%s"!' "$operation_for_assert" ;;
	esac
	unset operation_for_assert
}
