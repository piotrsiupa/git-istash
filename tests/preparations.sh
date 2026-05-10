#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi

GIT_CONFIG_SYSTEM=/dev/null
GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_SYSTEM
export GIT_CONFIG_GLOBAL

check_if_in_test_dir() {
	if [ -e '.git' ] || [ -e '../.git' ] || [ -e '../../.git' ] || [ -e '../../../.git' ]
	then
		printf 'It looks like we'\''re not in the test directory!\n' 1>&2
		exit 1
	fi
}
#shellcheck disable=SC2164
cd -
check_if_in_test_dir
#shellcheck disable=SC2164
cd -

prepare_repository() {
	git init --initial-branch=master
	if [ ! -e '.git' ]
	then
		printf 'Failed to create a test repository!\n' 1>&2
		exit 1
	fi

	git config --local user.email 'test@localhost'
	git config --local user.name 'test'

	git commit --allow-empty -m 'Initial commit'

	# Common ignored files for all tests (except for tests that explicitele remove them).
	mkdir -p .git/info
	printf 'ignored?\n' >>.git/info/exclude
	printf 'ignored0\n' >ignored0
	printf 'ignored1\n' >ignored1

	git remote add 'my-origin' "file://$(dirname "$(dirname "$(dirname "$(pwd -L)")")")/remote-for-tests"
	git fetch --quiet 'my-origin'
	git branch --set-upstream-to='my-origin/my-branch'
	
	# Set a color that is "normal" by default, thus making testing it harder.
	GIT_CONFIG_COUNT=1
	GIT_CONFIG_KEY_0='color.istash.summary.header'
	GIT_CONFIG_VALUE_0='blue'
	export GIT_CONFIG_COUNT
	export GIT_CONFIG_KEY_0
	export GIT_CONFIG_VALUE_0
	
	case "${HINT-}" in
		'') ;;
		'ALL-HINTS') ;;
		'ENBL-HINT') ADVICE_VALUE='true' ;;
		'ENBL-HINT-SHORT') ADVICE_VALUE='1' ;;
		'ENBL-HINT-ALT') ADVICE_VALUE='on' ;;
		'NO-HINTS') ;;
		'NO-ADVICE') ;;
		'DSBL-HINT') ADVICE_VALUE='false' ;;
		'DSBL-HINT-SHORT') ADVICE_VALUE='0' ;;
		'DSBL-HINT-ALT') ADVICE_VALUE='off' ;;
		*) fail 'Unknown hint setting "%s"!\n' "$HINT"
	esac
	if [ -n "${ADVICE_VALUE-}" ]
	then
		#shellcheck disable=SC2153
		printf '%s\n' "$ADVICE_NAMES" \
		| while read -r ADVICE_NAME
		do
			git config --local "advice.$ADVICE_NAME" "$ADVICE_VALUE"
		done
	fi
}
