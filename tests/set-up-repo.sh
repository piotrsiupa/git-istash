#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


#shellcheck disable=SC2164
cd -

export GIT_CONFIG_SYSTEM=/dev/null
export GIT_CONFIG_GLOBAL=/dev/null

if [ -e '.git' ] || [ -e '../.git' ] || [ -e '../../.git' ] || [ -e '../../../.git' ]
then
	printf 'It looks like we'\''re not in the test directory!\n' 1>&2
	exit 1
fi
git init --initial-branch=master
if [ ! -e '.git' ]
then
	printf 'Failed to create a test repository!\n' 1>&2
	exit 1
fi

git config --local user.email 'test@localhost'
git config --local user.name 'test'

git commit --allow-empty -m 'Initial commit'

mkdir -p .git/info
printf 'ignored?\n' >>.git/info/exclude
printf 'ignored0\n' >ignored0
printf 'ignored1\n' >ignored1

git remote add 'my-origin' "file://$(dirname "$(dirname "$(dirname "$(pwd -L)")")")/remote-for-tests"
git fetch --quiet 'my-origin'
git branch --set-upstream-to='my-origin/my-branch'

#shellcheck disable=SC2164
cd -
