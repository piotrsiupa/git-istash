. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_CALL_STYLE

__end_of_initialization__

__test_section__ '"--help" help'
if IS_GET_OPTIONS_STANDALONE
then
	assert_exit_code 0 "$GET_OPTIONS_COMMAND" --help
	assert_outputs '
		.{20,}+\n
		(.|\n)+\n
		Usage:\tget_options .+\n
		(.|\n)+\n
		Options:\n.+
		(.|\n)+
	' '
	'
else
	assert_exit_code 2 "$GET_OPTIONS_COMMAND" --help
	assert_outputs '' 'fatal: unknown option `--help'\'' for get_options'
fi


if is_facet_active 'short-options'
then
	__test_section__ '"-h" help'
	if IS_GET_OPTIONS_STANDALONE
	then
		assert_exit_code 0 "$GET_OPTIONS_COMMAND" -h
		assert_outputs '
			.{20,}+\n
			(.|\n)+\n
			Usage:\tget_options .+\n
			(.|\n)+\n
			Options:\n.+
			(.|\n)+
		' '
		'
	else
		assert_exit_code 2 "$GET_OPTIONS_COMMAND" -h
		assert_outputs '' 'fatal: unknown option `-h'\'' for get_options'
	fi
fi

__test_section__ '"--version" version'
if IS_GET_OPTIONS_STANDALONE
then
	assert_exit_code 0 "$GET_OPTIONS_COMMAND" --version
	assert_outputs '
		get_options version [1-9][0-9]*\.([1-9][0-9]*|0)\.([1-9][0-9]*|0)\n
		Author: Piotr Siupa
	' '
	'
else
	assert_exit_code 2 "$GET_OPTIONS_COMMAND" --version
	assert_outputs '' 'fatal: unknown option `--version'\'' for get_options'
fi

if is_facet_active 'short-options'
then
	__test_section__ '"-V" version'
	if IS_GET_OPTIONS_STANDALONE
	then
		assert_exit_code 0 "$GET_OPTIONS_COMMAND" -V
		assert_outputs '
			get_options version [1-9][0-9]*\.([1-9][0-9]*|0)\.([1-9][0-9]*|0)\n
			Author: Piotr Siupa
		' '
		'
	else
		assert_exit_code 2 "$GET_OPTIONS_COMMAND" -V
		assert_outputs '' 'fatal: unknown option `-V'\'' for get_options'
	fi
fi
