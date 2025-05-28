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
# Note that the arguments of these functions are not thoroughly validated. Familiarize yourself with them before trying to use them. (Read through the entire tree of sourced scripts. This basically equates to all the scripts in this directory (no subdirs) excluding `run.sh`.)
# Note that streams 4..8 are used by scripts (here and in `run.sh`) and they shouldn't be touched. (Stream 3 is used to print assertion errors and you can write to it.)

set -e

cd ../../..
WAS_IT_CALLED_FROM_COMMONS_SH='affirmative'
. ./set-up-repo.sh
. ./utils.sh
. ./assertions.sh
unset WAS_IT_CALLED_FROM_COMMONS_SH
cd -
