. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE

__end_of_initialization__

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'Unknown short option'
assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' -c --vidi=qwerty --veni -axdy 
assert_outputs '.*' 'error: unknown switch `x'\'

__test_section__ 'Unknown long option'
assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' -c --xyz --vidi=qwerty --veni -ady
assert_outputs '.*' 'error: unknown option `xyz'\'

__test_section__ 'Short option without the required argument'
assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' -c --vidi=qwerty --veni -ad
assert_outputs '.*' 'error: switch `d'\'' requires a value'

__test_section__ 'Long option without the required argument'
assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' -c --veni -ady --vidi
assert_outputs '.*' 'error: option `vidi'\'' requires a value'

__test_section__ 'Abbreviated long option without the required argument'
assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' -c --veni -ady --vid
assert_outputs '.*' 'error: option `vidi'\'' requires a value'

__test_section__ 'Long option with an unexpected argument'
assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' -c --vidi=qwerty --veni=inev -ady
assert_outputs '.*' 'error: option `veni'\'' takes no value'

__test_section__ 'Abbreviated long option with an unexpected argument'
assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' -c --vidi=qwerty --ve=inev -ady
assert_outputs '.*' 'error: option `veni'\'' takes no value'

__test_section__ 'Ambiguous option abbreviation'
assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' --ve -c --vic --vi=qwerty -ady
assert_outputs '.*' 'error: ambiguous option abbreviation `vi'\'

__test_section__ 'Ambiguous option abbreviation when one option is abbreviation of another'
assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'abcde,xyz,abc' --abcd -c --ab -ady
assert_outputs '.*' 'error: ambiguous option abbreviation `ab'\'

__test_section__ 'Short option without the required argument after a non-option'
if IS_POSIXLY_ON
then
	assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' -c --vidi=qwerty blah --veni -ad
	assert_outputs " -c --vidi 'qwerty' -- 'blah' '--veni' '-ad'" ''
else
	assert_exit_code 1 get_options $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici' -c --vidi=qwerty blah --veni -ad
	assert_outputs '.*' 'error: switch `d'\'' requires a value'
fi
