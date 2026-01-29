. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_GET_OPTIONS_MODE

__end_of_initialization__

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'Without arguments'
test_get_options_success \
	'' \
	'' \
	"" \
	" --" \
	" --" \
	" --" \
	

__test_section__ 'Without only --'
test_get_options_success \
	'' \
	'' \
	" '--'" \
	" --" \
	" --" \
	" -- '--'" \
	--

__test_section__ 'With an argument'
test_get_options_success \
	'' \
	'' \
	" 'abcd'" \
	" -- 'abcd'" \
	" -- 'abcd'" \
	" -- 'abcd'" \
	abcd

__test_section__ 'With an empty argument'
test_get_options_success \
	'' \
	'' \
	" ''" \
	" -- ''" \
	" -- ''" \
	" -- ''" \
	''

__test_section__ 'With some arguments'
test_get_options_success \
	'' \
	'' \
	" 'abcd' 'a b'\\\\''c d'" \
	" -- 'abcd' 'a b'\\\\''c d'" \
	" -- 'abcd' 'a b'\\\\''c d'" \
	" -- 'abcd' 'a b'\\\\''c d'" \
	abcd 'a b'\''c d'

__test_section__ 'With "--" before arguments'
test_get_options_success \
	'' \
	'' \
	" '--' 'abcd' 'a b'\\\\''c d'" \
	" -- 'abcd' 'a b'\\\\''c d'" \
	" -- 'abcd' 'a b'\\\\''c d'" \
	" -- '--' 'abcd' 'a b'\\\\''c d'" \
	-- abcd 'a b'\''c d'

__test_section__ 'With "--" in middle of arguments'
test_get_options_success \
	'' \
	'' \
	" 'abcd' '--' 'a b'\\\\''c d'" \
	" -- 'abcd' 'a b'\\\\''c d'" \
	" -- 'abcd' '--' 'a b'\\\\''c d'" \
	" -- 'abcd' '--' 'a b'\\\\''c d'" \
	abcd -- 'a b'\''c d'

__test_section__ 'With "--" after arguments'
test_get_options_success \
	'' \
	'' \
	" 'abcd' 'a b'\\\\''c d' '--'" \
	" -- 'abcd' 'a b'\\\\''c d'" \
	" -- 'abcd' 'a b'\\\\''c d' '--'" \
	" -- 'abcd' 'a b'\\\\''c d' '--'" \
	abcd 'a b'\''c d' --

__test_section__ 'With thinks looking like options after "--"'
test_get_options_success \
	'' \
	'' \
	" 'abcd' 'a b'\\\\''c d' '--' '-abcd' '--abcd'" \
	" -- 'abcd' 'a b'\\\\''c d' '-abcd' '--abcd'" \
	" -- 'abcd' 'a b'\\\\''c d' '--' '-abcd' '--abcd'" \
	" -- 'abcd' 'a b'\\\\''c d' '--' '-abcd' '--abcd'" \
	abcd 'a b'\''c d' -- -abcd --abcd

__test_section__ 'With a few "--"'
test_get_options_success \
	'' \
	'' \
	" '--' 'abcd' '--' 'a b'\\\\''c d' '--'" \
	" -- 'abcd' '--' 'a b'\\\\''c d' '--'" \
	" -- 'abcd' '--' 'a b'\\\\''c d' '--'" \
	" -- '--' 'abcd' '--' 'a b'\\\\''c d' '--'" \
	-- abcd -- 'a b'\''c d' --
