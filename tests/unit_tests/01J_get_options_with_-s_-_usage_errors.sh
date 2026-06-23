. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE
PARAMETRIZE_GET_OPTIONS_SINGLE_DEFINITION 'SINGLE-DEF'

__end_of_initialization__

__test_section__ 'Without option definitions'
assert_exit_code 2 run_get_options
assert_outputs '' 'fatal: not enough arguments for get_options'

__test_section__ 'With duplicated short option (without arguments)'
assert_exit_code 2 run_get_options 'a,b:,c,a,d:,e::,f::'
assert_outputs '' 'fatal: option `-a'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated short option (with arguments)'
assert_exit_code 2 run_get_options 'a,b:,c,b:,d:,e::,f::'
assert_outputs '' 'fatal: option `-b'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated short option (mixed arguments)'
assert_exit_code 2 run_get_options 'a,b:,c,a:,d:,e::,f::'
assert_outputs '' 'fatal: option `-a'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option (without arguments)'
assert_exit_code 2 run_get_options 'thingy,other,something:,other,object::'
assert_outputs '' 'fatal: option `--other'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option (with arguments)'
assert_exit_code 2 run_get_options 'thingy,other:,something:,other:,object::'
assert_outputs '' 'fatal: option `--other'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option (mixed arguments)'
assert_exit_code 2 run_get_options 'thingy,other:,something:,other,object::'
assert_outputs '' 'fatal: option `--other'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option containing whitespace'
assert_exit_code 2 run_get_options 'thingy,some - other:,something:,some - other:,object::'
assert_outputs '' 'fatal: option `--some - other'\'' repeats in options definition for get_options'

if ! IS_WHITESPACE_STRIPPING_ON
then
	
	__test_section__ 'With duplicated whitespace-only option'
	assert_exit_code 2 run_get_options "thingy,$tab:,something:,$tab:,object::"
	assert_outputs '' 'fatal: option `-\t'\'' repeats in options definition for get_options'
	
	__test_section__ 'With duplicated new-line-only option'
	assert_exit_code 2 run_get_options "thingy,$nl$nl:,something:,$nl$nl:,object::"
	assert_outputs '' 'fatal: option `--\n\n'\'' repeats in options definition for get_options'
	
fi

__test_section__ 'With unnamed option (at the beginning)'
assert_exit_code 2 run_get_options ',a,b:,other:,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: empty entry in options definition for get_options'

__test_section__ 'With unnamed option (in the middle)'
assert_exit_code 2 run_get_options 'a,b:,other:,c,d:,,something:,e::,f::,object::'
assert_outputs '' 'fatal: empty entry in options definition for get_options'

__test_section__ 'With unnamed option (at the end)'
assert_exit_code 2 run_get_options 'a,b:,other:,c,d:,something:,e::,f::,object::,'
assert_outputs '' 'fatal: empty entry in options definition for get_options'

__test_section__ 'With unnamed option (":" at the beginning)'
assert_exit_code 2 run_get_options ':,a,b:,other:,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: empty entry in options definition for get_options'

__test_section__ 'With unnamed option ("::" at the beginning)'
assert_exit_code 2 run_get_options '::,a,b:,other:,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: empty entry in options definition for get_options'

__test_section__ 'With unnamed option (":" in the middle)'
assert_exit_code 2 run_get_options 'a,b:,other:,c,d:,:,something:,e::,f::,object::'
assert_outputs '' 'fatal: empty entry in options definition for get_options'

__test_section__ 'With unnamed option ("::" in the middle)'
assert_exit_code 2 run_get_options 'a,b:,other:,c,d:,::,something:,e::,f::,object::'
assert_outputs '' 'fatal: empty entry in options definition for get_options'

__test_section__ 'With unnamed option (":" at the end)'
assert_exit_code 2 run_get_options 'a,b:,other:,c,d:,something:,e::,f::,object::,:'
assert_outputs '' 'fatal: empty entry in options definition for get_options'

__test_section__ 'With unnamed option ("::" at the end)'
assert_exit_code 2 run_get_options 'a,b:,other:,c,d:,something:,e::,f::,object::,::'
assert_outputs '' 'fatal: empty entry in options definition for get_options'

__test_section__ 'With "-" as a short option'
assert_exit_code 2 run_get_options 'a,b:,other:,c,d:,-:,something:,e::,f::,object::'
assert_outputs '' 'fatal: `-'\'' in short options definition for get_options'

__test_section__ 'With triple ":" at the end of a short options'
assert_exit_code 2 run_get_options 'a,b:,o:::,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: triple `:'\'' in options definition for get_options'

__test_section__ 'With triple ":" at the end of a long options'
assert_exit_code 2 run_get_options 'a,b:,other:::,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: triple `:'\'' in options definition for get_options'

__test_section__ 'With more than three ":" next to each other at the end of a short options'
assert_exit_code 2 run_get_options 'a,b:,o:::::,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: triple `:'\'' in options definition for get_options'

__test_section__ 'With more than three ":" next to each other at the end of a long options'
assert_exit_code 2 run_get_options 'a,b:,other:::::,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: triple `:'\'' in options definition for get_options'

__test_section__ 'With "=" in a name of a long option'
assert_exit_code 2 run_get_options 'a,b:,other:,c,d:,somet=hing:,e::,f::,object::'
assert_outputs '' 'fatal: `='\'' in a name of a long option in definition for get_options'

__test_section__ 'Unknown option to get_options (at the beginning)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" -x $WHITESPACE_FLAG $MODE_FLAGS 'a,b:,other:,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: unknown option `-x'\'' for get_options'

__test_section__ 'Unknown option to get_options (in the middle)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $WHITESPACE_FLAG -x $MODE_FLAGS 'a,b:,other:,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: unknown option `-x'\'' for get_options'

__test_section__ 'Unknown option to get_options (at the end)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $WHITESPACE_FLAG $MODE_FLAGS -x 'a,b:,other:,c,d:,something:,e::,f::,object::'
assert_outputs '' 'fatal: unknown option `-x'\'' for get_options'
