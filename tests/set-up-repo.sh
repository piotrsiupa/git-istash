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

git init --initial-branch=master

git config --local user.email 'test@localhost'
git config --local user.name 'test'

git commit --allow-empty -m 'Initial commit'

printf 'ignored?\n' >>.git/info/exclude
printf 'ignored0\n' >ignored0
printf 'ignored1\n' >ignored1

git remote add 'my-origin' "file://$(dirname "$(dirname "$(pwd -L)")")/remote-for-tests"
git fetch --quiet 'my-origin'
git branch --set-upstream-to='my-origin/my-branch'

#shellcheck disable=SC2164
cd -
