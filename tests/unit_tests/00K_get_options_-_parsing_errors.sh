. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE

__end_of_initialization__

if IS_PARTIAL_PARSE_ON
then
	__test_section__ 'Unknown short option'
	#shellcheck disable=SC2086
	assert_exit_code 0 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --vidi=qwerty --veni -axdy 
	assert_outputs " -c --vidi 'qwerty' --veni -a -- '-xdy'" ''
	
	__test_section__ 'Unknown long option'
	#shellcheck disable=SC2086
	assert_exit_code 0 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --xyz --vidi=qwerty --veni -ady
	assert_outputs " -c -- '--xyz' '--vidi=qwerty' '--veni' '-ady'" ''
else
	__test_section__ 'Unknown short option'
	#shellcheck disable=SC2086
	assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --vidi=qwerty --veni -axdy 
	assert_outputs '.*' 'error: unknown switch `x'\'
	
	__test_section__ 'Unknown whitespace short option'
	#shellcheck disable=SC2086
	assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --vidi=qwerty --veni -a\ dy 
	assert_outputs '.*' 'error: unknown switch ` '\'
	
	__test_section__ 'Unknown new-line short option'
	#shellcheck disable=SC2086
	assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --vidi=qwerty --veni '-a
dy'
	assert_outputs '.*' 'error: unknown switch `\n'\'
	
	__test_section__ 'Unknown long option'
	#shellcheck disable=SC2086
	assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --xyz --vidi=qwerty --veni -ady
	assert_outputs '.*' 'error: unknown option `xyz'\'
	
	__test_section__ 'Unknown whitespace-only long option'
	#shellcheck disable=SC2086
	assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --\	\	 --vidi=qwerty --veni -ady
	assert_outputs '.*' 'error: unknown option `		'\'
	
	__test_section__ 'Unknown new-line-only long option'
	#shellcheck disable=SC2086
	assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --'

' --vidi=qwerty --veni -ady
	assert_outputs '.*' 'error: unknown option `\n\n'\'
fi

__test_section__ 'Short option without the required argument'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --vidi=qwerty --veni -ad
assert_outputs '.*' 'error: switch `d'\'' requires a value'

__test_section__ 'Whitespace short option without the required argument'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd: :' 'veni,vidi:,vici::' -c --vidi=qwerty --veni -a\  #
assert_outputs '.*' 'error: switch ` '\'' requires a value'

if IS_POSIXLY_ON
then
	__test_section__ 'Short option without the required argument after a non-option'
	#shellcheck disable=SC2086
	assert_exit_code 0 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --vidi=qwerty blah --veni -ad
	assert_outputs " -c --vidi 'qwerty' -- 'blah' '--veni' '-ad'" ''
else
	__test_section__ 'Short option without the required argument after a non-option'
	#shellcheck disable=SC2086
	assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --vidi=qwerty blah --veni -ad
	assert_outputs '.*' 'error: switch `d'\'' requires a value'
fi

__test_section__ 'Long option without the required argument'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --veni -ady --vidi
assert_outputs '.*' 'error: option `vidi'\'' requires a value'

__test_section__ 'Whitespace-only long option without the required argument'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::,   :' -c --veni -ady --\ \ \  #
assert_outputs '.*' 'error: option `   '\'' requires a value'

__test_section__ 'Abbreviated long option without the required argument'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --veni -ady --vid
assert_outputs '.*' 'error: option `vidi'\'' requires a value'

__test_section__ 'Long option with an unexpected argument'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --vidi=qwerty --veni=inev -ady
assert_outputs '.*' 'error: option `veni'\'' takes no value'

__test_section__ 'Whitespace-only long option with an unexpected argument'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::,   ' -c --vidi=qwerty --\ \ \ =inev -ady
assert_outputs '.*' 'error: option `   '\'' takes no value'

__test_section__ 'Abbreviated long option with an unexpected argument'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' -c --vidi=qwerty --ve=inev -ady
assert_outputs '.*' 'error: option `veni'\'' takes no value'

__test_section__ 'Ambiguous option abbreviation'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::' --ve -c --vic --vi=qwerty -ady
assert_outputs '.*' 'error: ambiguous option abbreviation `vi'\'

__test_section__ 'Ambiguous whitespace-only option abbreviation'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::,  	,   ' --ve -c --vic --\ \ =qwerty -ady
assert_outputs '.*' 'error: ambiguous option abbreviation `  '\'

__test_section__ 'Ambiguous new-line option abbreviation'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'veni,vidi:,vici::,

 ,

	' --ve -c --vic --'

'=qwerty -ady
assert_outputs '.*' 'error: ambiguous option abbreviation `\n\n'\'

__test_section__ 'Ambiguous option abbreviation when one option is abbreviation of another'
#shellcheck disable=SC2086
assert_exit_code 1 "$GET_OPTIONS_COMMAND" $MODE_FLAGS 'ab:cd:' 'abcde,xyz,abc' --abcd -c --ab -ady
assert_outputs '.*' 'error: ambiguous option abbreviation `ab'\'
