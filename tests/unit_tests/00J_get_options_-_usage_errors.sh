. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE

__end_of_initialization__

__test_section__ 'Without option definitions'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS
assert_outputs '' 'fatal: not enough arguments for get_options'

__test_section__ 'With only short options definition'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS ''
assert_outputs '' 'fatal: not enough arguments for get_options'

__test_section__ 'With duplicated short option (without arguments)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cad:e::f::' ''
assert_outputs '' 'fatal: option `-a'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated short option (with arguments)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cb:d:e::f::' ''
assert_outputs '' 'fatal: option `-b'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated short option (mixed arguments)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:ca:d:e::f::' ''
assert_outputs '' 'fatal: option `-a'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated whitespace short option'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:c d:e:: f::' ''
assert_outputs '' 'fatal: option `- '\'' repeats in options definition for get_options'

__test_section__ 'With duplicated new-line short option'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:c
d:e::
f::' ''
assert_outputs '' 'fatal: option `-\n'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option (without arguments)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other,something:,other,object::'
assert_outputs '' 'fatal: option `--other'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option (with arguments)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,something:,other:,object::'
assert_outputs '' 'fatal: option `--other'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated long option (mixed arguments)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,something:,other,object::'
assert_outputs '' 'fatal: option `--other'\'' repeats in options definition for get_options'

__test_section__ 'With duplicated whitespace-only long option'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy, 	 :,something:, 	 :,object::'
assert_outputs '' 'fatal: option `-- 	 '\'' repeats in options definition for get_options'

__test_section__ 'With duplicated new-line-only long option'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,

:,something:,

:,object::'
assert_outputs '' 'fatal: option `--\n\n'\'' repeats in options definition for get_options'

__test_section__ 'With unnamed long option (at the beginning)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' ',other:,something:,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (in the middle)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (at the end)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,something:,'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed short option (starts with ":")'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS ':ab:cd:e::f::' ''
assert_outputs '' 'fatal: empty entry in short options definition for get_options'

__test_section__ 'With unnamed short option (starts with "::")'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '::ab:cd:e::f::' ''
assert_outputs '' 'fatal: empty entry in short options definition for get_options'

__test_section__ 'With unnamed long option (":" at the beginning)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' ':,other:,something:,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option ("::" at the beginning)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' '::,other:,something:,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (":" in the middle)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,:,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option ("::" in the middle)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,::,object::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (":" at the end)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,something:,:'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option ("::" at the end)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,something:,::'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With triplicated ":" in short options'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:::cd:e::f::' ''
assert_outputs '' 'fatal: triple `:'\'' in short options definition for get_options'

__test_section__ 'With more than ":" next to each other in short options'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:::::cd:e::f::' ''
assert_outputs '' 'fatal: triple `:'\'' in short options definition for get_options'

__test_section__ 'With triplicated ":" in long options'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:::,something:,object::'
assert_outputs '' 'fatal: triple `:'\'' in long options definition for get_options'

__test_section__ 'With more than three ":" next to each other in long options'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:::::,something:,object::'
assert_outputs '' 'fatal: triple `:'\'' in long options definition for get_options'

__test_section__ 'With ":" in a middle of long option (without parameter)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,somet:hing,object::'
assert_outputs '' 'fatal: `:'\'' in a name of a long option in definition for get_options'

__test_section__ 'With double ":" in a middle of long option (without parameter)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,somet::hing,object::'
assert_outputs '' 'fatal: `:'\'' in a name of a long option in definition for get_options'

__test_section__ 'With ":" in a middle of long option (with parameter)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,somet:hing:,object::'
assert_outputs '' 'fatal: `:'\'' in a name of a long option in definition for get_options'

__test_section__ 'With double ":" in a middle of long option (with parameter)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,somet::hing:,object::'
assert_outputs '' 'fatal: `:'\'' in a name of a long option in definition for get_options'

__test_section__ 'With ":" in a middle of long option (with optional parameter)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,somet:hing::,object::'
assert_outputs '' 'fatal: `:'\'' in a name of a long option in definition for get_options'

__test_section__ 'With double ":" in a middle of long option (with optional parameter)'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,somet::hing::,object::'
assert_outputs '' 'fatal: `:'\'' in a name of a long option in definition for get_options'

__test_section__ 'With "=" in a name of long option'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" $MODE_FLAGS '' 'thingy,other:,somet=hing:,object'
assert_outputs '' 'fatal: `='\'' in a name of a long option in definition for get_options'

__test_section__ 'Unknown option to get_options'
#shellcheck disable=SC2086
assert_exit_code 2 "$GET_OPTIONS_COMMAND" -x $MODE_FLAGS '' 'thingy,other:,something:,object::'
assert_outputs '' 'fatal: unknown option `-x'\'' for get_options'
