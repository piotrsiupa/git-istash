. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE

__end_of_initialization__

__test_section__ 'Without arguments'
test_get_options_success \
	'ab:cd:' \
	'' \
	"" \
	" --" \
	" --" \
	" --" \
	

__test_section__ 'Without only --'
test_get_options_success \
	'ab:cd:' \
	'' \
	" '--'" \
	" --" \
	" --" \
	" -- '--'" \
	--

__test_section__ 'With an argument'
test_get_options_success \
	'ab:cd:' \
	'' \
	" 'abcd'" \
	" -- 'abcd'" \
	" -- 'abcd'" \
	" -- 'abcd'" \
	abcd

__test_section__ 'With an option'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -a" \
	" -a --" \
	" -a --" \
	" -a --" \
	-a

__test_section__ 'With an option with a parameter'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -b ' xyz '" \
	" -b ' xyz ' --" \
	" -b ' xyz ' --" \
	" -b ' xyz ' --" \
	-b ' xyz '

__test_section__ 'With an option with an empty parameter'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -b ''" \
	" -b '' --" \
	" -b '' --" \
	" -b '' --" \
	-b ''

__test_section__ 'With a few options'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -b ' xyz ' -c -d '-a'" \
	" -b ' xyz ' -c -d '-a' --" \
	" -b ' xyz ' -c -d '-a' --" \
	" -b ' xyz ' -c -d '-a' --" \
	-b ' xyz ' -c -d -a

__test_section__ 'With a few repeated options'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -b ' xyz ' -c -d '-a' -b 'qwerty' -a -c" \
	" -b ' xyz ' -c -d '-a' -b 'qwerty' -a -c --" \
	" -b ' xyz ' -c -d '-a' -b 'qwerty' -a -c --" \
	" -b ' xyz ' -c -d '-a' -b 'qwerty' -a -c --" \
	-b ' xyz ' -c -d-a -b qwerty -a -c

__test_section__ 'With a few merged options'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -b ' xyz ' -c -d 'a'" \
	" -b ' xyz ' -c -d 'a' --" \
	" -b ' xyz ' -c -d 'a' --" \
	" -b ' xyz ' -c -d 'a' --" \
	-b' xyz ' -cda

__test_section__ 'With a few merged and repeated options'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty '" \
	" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' --" \
	" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' --" \
	" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' --" \
	-b' xyz ' -cda -acb' qwerty '

__test_section__ 'With some options and arguments'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -c -b 'a' 'abcd' -d 'a' 'a b'\\\\''c d' -a" \
	" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -- 'abcd' '-da' 'a b'\\\\''c d' '-a'" \
	" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" \
	-cba abcd -da 'a b'\''c d' -a

__test_section__ 'With some options and arguments and "--" before arguments'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -c -b 'a' -d 'a' -a '--' 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -a -- '--' 'abcd' 'a b'\\\\''c d'" \
	-cba -da -a -- abcd 'a b'\''c d'

__test_section__ 'With some options and arguments and "--" in middle of arguments'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -c -b 'a' 'abcd' -d 'a' -a '--' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -- 'abcd' '-da' '-a' '--' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -a -- 'abcd' '--' 'a b'\\\\''c d'" \
	-cba abcd -da -a -- 'a b'\''c d'

__test_section__ 'With some options and arguments and "--" after arguments'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -c -b 'a' 'abcd' -d 'a' 'a b'\\\\''c d' -a '--'" \
	" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -- 'abcd' '-da' 'a b'\\\\''c d' '-a' '--'" \
	" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d' '--'" \
	-cba abcd -da 'a b'\''c d' -a --

__test_section__ 'With some options and arguments and things looking like options after "--"'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -c -b 'a' 'abcd' -d 'a' '--' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" \
	" -c -b 'a' -d 'a' -- 'abcd' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" \
	" -c -b 'a' -- 'abcd' '-da' '--' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" \
	" -c -b 'a' -d 'a' -- 'abcd' '--' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" \
	-cba abcd -da -- -a 'a b'\''c d' -das\'\\dfg' '

__test_section__ 'With some options and arguments and a few "--"'
test_get_options_success \
	'ab:cd:' \
	'' \
	" -c -b 'a' 'abcd' '--' '-da' '--' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" \
	" -c -b 'a' -- 'abcd' '-da' '--' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" \
	" -c -b 'a' -- 'abcd' '--' '-da' '--' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" \
	" -c -b 'a' -- 'abcd' '--' '-da' '--' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" \
	-cba abcd -- -da -- -a 'a b'\''c d' -dasdfg --
