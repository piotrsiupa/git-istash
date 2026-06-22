. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE
PARAMETRIZE_GET_OPTIONS_SINGLE_DEFINITION 'MULTI-DEF'

__end_of_initialization__

__test_section__ 'Without option definitions'
assert_exit_code 2 run_get_options
assert_outputs '' 'fatal: not enough arguments for get_options'

__test_section__ 'With only short options definition'
assert_exit_code 2 run_get_options ''
assert_outputs '' 'fatal: not enough arguments for get_options'

__test_section__ 'With duplicated short option (without arguments)'
assert_exit_code 2 run_get_options 'ab:cad:e::f::' ''
assert_outputs '' 'fatal: option `-a'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated short option (with arguments)'
assert_exit_code 2 run_get_options 'ab:cb:d:e::f::' ''
assert_outputs '' 'fatal: option `-b'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated short option (mixed arguments)'
assert_exit_code 2 run_get_options 'ab:ca:d:e::f::' ''
assert_outputs '' 'fatal: option `-a'\'' repeats in options definition for get_options'

if ! IS_WHITESPACE_STRIPPING_ON
then
	
	__test_section__ 'With duplicated whitespace short option'
	assert_exit_code 2 run_get_options 'ab:c d:e:: f::' ''
	assert_outputs '' 'fatal: option `- '\'' repeats in options definition for get_options'
	
	__test_section__ 'With duplicated new-line short option'
	assert_exit_code 2 run_get_options "ab:c${nl}d:e::${nl}f::" ''
	assert_outputs '' 'fatal: option `-\n'\'' repeats in options definition for get_options'
	
fi

__test_section__ 'With duplicated long option (without arguments)'
assert_exit_code 2 run_get_options '' 'thingy,other,something:,other,object::'
assert_outputs '' 'fatal: option `--other'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option (with arguments)'
assert_exit_code 2 run_get_options '' 'thingy,other:,something:,other:,object::'
assert_outputs '' 'fatal: option `--other'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option (mixed arguments)'
assert_exit_code 2 run_get_options '' 'thingy,other:,something:,other,object::'
assert_outputs '' 'fatal: option `--other'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option containing whitespace'
assert_exit_code 2 run_get_options '' 'thingy,some - other:,something:,some - other:,object::'
assert_outputs '' 'fatal: option `--some - other'\'' repeats in options definition for get_options'

if ! IS_WHITESPACE_STRIPPING_ON
then
	
	__test_section__ 'With duplicated whitespace-only long option'
	assert_exit_code 2 run_get_options '' "thingy, $tab :,something:, $tab :,object::"
	assert_outputs '' 'fatal: option `-- \t '\'' repeats in options definition for get_options'
	
	__test_section__ 'With duplicated new-line-only long option'
	assert_exit_code 2 run_get_options '' "thingy,$nl$nl:,something:,$nl$nl:,object::"
	assert_outputs '' 'fatal: option `--\n\n'\'' repeats in options definition for get_options'
	
fi

__test_section__ 'With unnamed long option (at the beginning)'
assert_exit_code 2 run_get_options '' ',other:,something:,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (in the middle)'
assert_exit_code 2 run_get_options '' 'thingy,other:,,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (at the end)'
assert_exit_code 2 run_get_options '' 'thingy,other:,something:,'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed short option (starts with ":")'
assert_exit_code 2 run_get_options ':ab:cd:e::f::' ''
assert_outputs '' 'fatal: empty entry in short options definition for get_options'

__test_section__ 'With unnamed short option (starts with "::")'
assert_exit_code 2 run_get_options '::ab:cd:e::f::' ''
assert_outputs '' 'fatal: empty entry in short options definition for get_options'

__test_section__ 'With unnamed long option (":" at the beginning)'
assert_exit_code 2 run_get_options '' ':,other:,something:,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option ("::" at the beginning)'
assert_exit_code 2 run_get_options '' '::,other:,something:,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (":" in the middle)'
assert_exit_code 2 run_get_options '' 'thingy,other:,:,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option ("::" in the middle)'
assert_exit_code 2 run_get_options '' 'thingy,other:,::,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (":" at the end)'
assert_exit_code 2 run_get_options '' 'thingy,other:,something:,:'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option ("::" at the end)'
assert_exit_code 2 run_get_options '' 'thingy,other:,something:,::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With "-" as a short option'
assert_exit_code 2 run_get_options 'ab:c-d:e::f::' ''
assert_outputs '' 'fatal: `-'\'' in short options definition for get_options'

__test_section__ 'With triplicated ":" in short options'
assert_exit_code 2 run_get_options 'ab:::cd:e::f::' ''
assert_outputs '' 'fatal: triple `:'\'' in short options definition for get_options'

__test_section__ 'With more than three ":" next to each other in short options'
assert_exit_code 2 run_get_options 'ab:::::cd:e::f::' ''
assert_outputs '' 'fatal: triple `:'\'' in short options definition for get_options'

__test_section__ 'With triplicated ":" at the end of a long option'
assert_exit_code 2 run_get_options '' 'thingy,other:::,something:,object::'
assert_outputs '' 'fatal: triple `:'\'' in long options definition for get_options'

__test_section__ 'With more than three ":" next to each other at the end of long option'
assert_exit_code 2 run_get_options '' 'thingy,other:::::,something:,object::'
assert_outputs '' 'fatal: triple `:'\'' in long options definition for get_options'

__test_section__ 'With "=" in a name of long option'
assert_exit_code 2 run_get_options '' 'thingy,other:,somet=hing:,object'
assert_outputs '' 'fatal: `='\'' in a name of a long option in definition for get_options'

__test_section__ 'Unknown option to get_options (at the beginning)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" -x $WHITESPACE_FLAG $MODE_FLAGS '' 'thingy,other:,something:,object::'
assert_outputs '' 'fatal: unknown option `-x'\'' for get_options'

__test_section__ 'Unknown option to get_options (in the middle)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $WHITESPACE_FLAG -x $MODE_FLAGS '' 'thingy,other:,something:,object::'
assert_outputs '' 'fatal: unknown option `-x'\'' for get_options'

__test_section__ 'Unknown option to get_options (at the end)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $WHITESPACE_FLAG $MODE_FLAGS -x '' 'thingy,other:,something:,object::'
assert_outputs '' 'fatal: unknown option `-x'\'' for get_options'
