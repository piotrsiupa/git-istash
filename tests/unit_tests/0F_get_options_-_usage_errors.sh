. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE 'MODE' 'options' 'DEFAULT' 'NO_REORDER'

__end_of_initialization__

case "$MODE" in
	NO_REORDER) MODE_FLAGS='-R' ;;
	*) MODE_FLAGS='' ;;
esac

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'Without option definitions'
assert_exit_code 2 get_options $MODE_FLAGS
assert_outputs '' 'fatal: not enough arguments for get_options'

__test_section__ 'With only short options definition'
assert_exit_code 2 get_options $MODE_FLAGS ''
assert_outputs '' 'fatal: not enough arguments for get_options'

__test_section__ 'With duplicated short option (without arguments)'
assert_exit_code 2 get_options $MODE_FLAGS 'ab:cad' ''
assert_outputs '' 'fatal: option -a repeats in options definition for get_options'

__test_section__ 'With duplicated short option (with arguments)'
assert_exit_code 2 get_options $MODE_FLAGS 'ab:cb:d' ''
assert_outputs '' 'fatal: option -b repeats in options definition for get_options'

__test_section__ 'With duplicated short option (mixed arguments)'
assert_exit_code 2 get_options $MODE_FLAGS 'ab:ca:d' ''
assert_outputs '' 'fatal: option -a repeats in options definition for get_options'

__test_section__ 'With duplicated long option (without arguments)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other,something:,other,object'
assert_outputs '' 'fatal: option --other repeats in options definition for get_options'

__test_section__ 'With duplicated long option (with arguments)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,something:,other:,object'
assert_outputs '' 'fatal: option --other repeats in options definition for get_options'

__test_section__ 'With duplicated long option (mixed arguments)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,something:,other,object'
assert_outputs '' 'fatal: option --other repeats in options definition for get_options'

__test_section__ 'With unnamed long option (at the beginning)'
assert_exit_code 2 get_options $MODE_FLAGS '' ',other:,something:,object'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (in the middle)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,,object'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (at the end)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,something:,'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed short option (starts with ":")'
assert_exit_code 2 get_options $MODE_FLAGS ':ab:cd' ''
assert_outputs '' 'fatal: empty entry in short options definition for get_options'

__test_section__ 'With unnamed long option (at the beginning)'
assert_exit_code 2 get_options $MODE_FLAGS '' ':,other:,something:,object'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (in the middle)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,:,object'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With unnamed long option (at the end)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,something:,:'
assert_outputs '' 'fatal: empty entry in long options definition for get_options'

__test_section__ 'With duplicated ":" in short options'
assert_exit_code 2 get_options $MODE_FLAGS 'ab::cd' ''
assert_outputs '' 'fatal: double : in short options definition for get_options'

__test_section__ 'With duplicated ":" in long options'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other::,something:,object'
assert_outputs '' 'fatal: double : in long options definition for get_options'

__test_section__ 'With ":" in a middle of long option (without parameter)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,somet:hing,object'
assert_outputs '' 'fatal: : in a name of a long option in definition for get_options'

__test_section__ 'With ":" in a middle of long option (with parameter)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,somet:hing:,object'
assert_outputs '' 'fatal: : in a name of a long option in definition for get_options'

__test_section__ 'With "=" in a name of long option'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,somet=hing:,object'
assert_outputs '' 'fatal: = in a name of a long option in definition for get_options'

__test_section__ 'White characters in short options definition (at the beginning)'
assert_exit_code 2 get_options $MODE_FLAGS '	ab:cd' ''
assert_outputs '' 'fatal: white character in short options definition for get_options'

__test_section__ 'White characters in short options definition (in a middle)'
assert_exit_code 2 get_options $MODE_FLAGS 'ab:
cd' ''
assert_outputs '' 'fatal: white character in short options definition for get_options'

__test_section__ 'White characters in short options definition (at the end)'
assert_exit_code 2 get_options $MODE_FLAGS 'ab:cd ' ''
assert_outputs '' 'fatal: white character in short options definition for get_options'

__test_section__ 'White characters in long options definition (at the beginning)'
assert_exit_code 2 get_options $MODE_FLAGS '' '	thingy,other:,something:,object'
assert_outputs '' 'fatal: white character in long options definition for get_options'

__test_section__ 'White characters in long options definition (in a middle)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,
something:,object'
assert_outputs '' 'fatal: white character in long options definition for get_options'

__test_section__ 'White characters in long options definition (at the end)'
assert_exit_code 2 get_options $MODE_FLAGS '' 'thingy,other:,something:,object '
assert_outputs '' 'fatal: white character in long options definition for get_options'

__test_section__ 'Unknown option to get_options'
assert_exit_code 2 get_options -x $MODE_FLAGS '' 'thingy,other:,something:,object '
assert_outputs '' 'fatal: unknown option -x for get_options'
