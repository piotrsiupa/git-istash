#!/usr/bin/env sh

if [ "$WAS_IT_CALLED_FROM_COMMONS_SH" != 'affirmative' ]
then
	printf 'This script is intended only to be used by "commons.sh"!\n' 1>&2
	exit 1
fi


# ================================= get_options ================================


#shellcheck disable=SC2120
PARAMETRIZE_GET_OPTIONS_MODE() { # [modes...]
	if [ $# -eq 0 ]
	then
		PARAMETRIZE 'MODE' 'options' 'DEFAULT' 'NO_REORDER'
	else
		PARAMETRIZE 'MODE' 'options' "$@"
	fi
	case "$MODE" in
		NO_REORDER)
			#shellcheck disable=SC2034
			MODE_FLAGS='-R'
			;;
		*)
			#shellcheck disable=SC2034
			MODE_FLAGS=''
			;;
	esac
}
IS_REORDER_ON() {
	test "$MODE" != 'NO_REORDER'
}

test_get_options_success() { # short_options long_options no_reorder_stdout reorder_stdout [argument_to_parse...]
	short_options="$1"
	long_options="$2"
	no_reorder_stdout="$3"
	reorder_stdout="$4"
	shift 4
	#shellcheck disable=SC2086
	assert_exit_code 0 get_options $MODE_FLAGS "$short_options" "$long_options" "$@"
	if IS_REORDER_ON
	then
		expected_stdout="$reorder_stdout"
	else
		expected_stdout="$no_reorder_stdout"
	fi
	assert_outputs "$expected_stdout" ''
	#shellcheck disable=SC2154
	eval set -- "$stdout"
	#shellcheck disable=SC2086
	assert_exit_code 0 get_options $MODE_FLAGS "$short_options" "$long_options" "$@"
	assert_outputs "$expected_stdout" ''
}
