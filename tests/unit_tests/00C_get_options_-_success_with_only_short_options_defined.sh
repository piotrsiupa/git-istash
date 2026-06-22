. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE

__end_of_initialization__

__test_section__ 'Without arguments'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	"" \
	" --" \
	" --" \
	" --" \
	

__test_section__ 'Without only --'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" '--'" \
	" --" \
	" --" \
	" -- '--'" \
	--

__test_section__ 'With an argument'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" 'abcd'" \
	" -- 'abcd'" \
	" -- 'abcd'" \
	" -- 'abcd'" \
	abcd

__test_section__ 'With an option'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -a" \
	" -a --" \
	" -a --" \
	" -a --" \
	-a

__test_section__ 'With an option with a parameter'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -b ' xyz '" \
	" -b ' xyz ' --" \
	" -b ' xyz ' --" \
	" -b ' xyz ' --" \
	-b ' xyz '

__test_section__ 'With an option with a parameter without space'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -b ' xyz '" \
	" -b ' xyz ' --" \
	" -b ' xyz ' --" \
	" -b ' xyz ' --" \
	-b' xyz '

__test_section__ 'With an option with an empty parameter'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -b ''" \
	" -b '' --" \
	" -b '' --" \
	" -b '' --" \
	-b ''

__test_section__ 'With an option with an optional parameter with a space'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -e '' ' xyz '" \
	" -e '' -- ' xyz '" \
	" -e '' -- ' xyz '" \
	" -e '' -- ' xyz '" \
	-e ' xyz '

__test_section__ 'With an option with an optional parameter'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -e ' xyz '" \
	" -e ' xyz ' --" \
	" -e ' xyz ' --" \
	" -e ' xyz ' --" \
	-e' xyz '

__test_section__ 'With an option with an empty parameter'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -e ''" \
	" -e '' --" \
	" -e '' --" \
	" -e '' --" \
	-e''

__test_section__ 'With a few options'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -b ' xyz ' -f '' -c -e 'xyz' -d '-a'" \
	" -b ' xyz ' -f '' -c -e 'xyz' -d '-a' --" \
	" -b ' xyz ' -f '' -c -e 'xyz' -d '-a' --" \
	" -b ' xyz ' -f '' -c -e 'xyz' -d '-a' --" \
	-b ' xyz ' -f -c -exyz -d -a

__test_section__ 'With a few repeated options'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -b ' xyz ' -f '' -c -f '' -d '-a' -e 'xyz' -b 'qwerty' -a -e '' -c" \
	" -b ' xyz ' -f '' -c -f '' -d '-a' -e 'xyz' -b 'qwerty' -a -e '' -c --" \
	" -b ' xyz ' -f '' -c -f '' -d '-a' -e 'xyz' -b 'qwerty' -a -e '' -c --" \
	" -b ' xyz ' -f '' -c -f '' -d '-a' -e 'xyz' -b 'qwerty' -a -e '' -c --" \
	-b ' xyz ' -f -c -f -d-a -exyz -b qwerty -a -e -c

__test_section__ 'With a few merged options'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -b ' xyz ' -e 'f' -c -d 'a' -a -f ''" \
	" -b ' xyz ' -e 'f' -c -d 'a' -a -f '' --" \
	" -b ' xyz ' -e 'f' -c -d 'a' -a -f '' --" \
	" -b ' xyz ' -e 'f' -c -d 'a' -a -f '' --" \
	-b' xyz ' -ef -cda -af

__test_section__ 'With a few merged and repeated options'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' -a -e 'f' -f '' -e 'xyz' -a -f 'e'" \
	" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' -a -e 'f' -f '' -e 'xyz' -a -f 'e' --" \
	" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' -a -e 'f' -f '' -e 'xyz' -a -f 'e' --" \
	" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' -a -e 'f' -f '' -e 'xyz' -a -f 'e' --" \
	-b' xyz ' -cda -acb' qwerty ' -aef -f -exyz -afe

__test_section__ 'With some options and arguments'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -c -b 'a' 'abcd' -d 'a' -e '' 'a b'\\\\''c d' -f 'xyz' -a" \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -- 'abcd' '-da' '-e' 'a b'\\\\''c d' '-fxyz' '-a'" \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a -- 'abcd' 'a b'\\\\''c d'" \
	-cba abcd -da -e 'a b'\''c d' -fxyz -a

__test_section__ 'With some options and arguments and "--" before arguments'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a '--' 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a -- '--' 'abcd' 'a b'\\\\''c d'" \
	-cba -da -e -fxyz -a -- abcd 'a b'\''c d'

__test_section__ 'With some options and arguments and "--" in middle of arguments'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -c -b 'a' 'abcd' -d 'a' -e '' -f 'xyz' -a '--' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -- 'abcd' '-da' '-e' '-fxyz' '-a' '--' 'a b'\\\\''c d'" \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a -- 'abcd' '--' 'a b'\\\\''c d'" \
	-cba abcd -da -e -fxyz -a -- 'a b'\''c d'

__test_section__ 'With some options and arguments and "--" after arguments'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -c -b 'a' 'abcd' -d 'a' -e '' 'a b'\\\\''c d' -f 'xyz' -a '--'" \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a -- 'abcd' 'a b'\\\\''c d'" \
	" -c -b 'a' -- 'abcd' '-da' '-e' 'a b'\\\\''c d' '-fxyz' '-a' '--'" \
	" -c -b 'a' -d 'a' -e '' -f 'xyz' -a -- 'abcd' 'a b'\\\\''c d' '--'" \
	-cba abcd -da -e 'a b'\''c d' -fxyz -a --

__test_section__ 'With some options and arguments and things looking like options after "--"'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -c -b 'a' 'abcd' -d 'a' -e '' '--' '-fxyz' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" \
	" -c -b 'a' -d 'a' -e '' -- 'abcd' '-fxyz' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" \
	" -c -b 'a' -- 'abcd' '-da' '-e' '--' '-fxyz' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" \
	" -c -b 'a' -d 'a' -e '' -- 'abcd' '--' '-fxyz' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" \
	-cba abcd -da -e -- -fxyz -a 'a b'\''c d' -das\'\\dfg' '

__test_section__ 'With some options and arguments and a few "--"'
test_get_options_success \
	'ab:cd:e::f::' \
	'' \
	" -c -b 'a' 'abcd' '--' '-da' '-e' '--' '-fxyz' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" \
	" -c -b 'a' -- 'abcd' '-da' '-e' '--' '-fxyz' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" \
	" -c -b 'a' -- 'abcd' '--' '-da' '-e' '--' '-fxyz' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" \
	" -c -b 'a' -- 'abcd' '--' '-da' '-e' '--' '-fxyz' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" \
	-cba abcd -- -da -e -- -fxyz -a 'a b'\''c d' -dasdfg --

__test_section__ 'With "," as a short option'
test_get_options_success \
	'ab:cd:,::f::' \
	'' \
	" -b ' xyz ' -f '' -c -',' 'xyz' -d '-a'" \
	" -b ' xyz ' -f '' -c -',' 'xyz' -d '-a' --" \
	" -b ' xyz ' -f '' -c -',' 'xyz' -d '-a' --" \
	" -b ' xyz ' -f '' -c -',' 'xyz' -d '-a' --" \
	-b ' xyz ' -f -c -,xyz -d -a

__test_section__ 'With "," in merged options'
test_get_options_success \
	'ab:c,:e::f::' \
	'' \
	" -b ' xyz ' -e 'f' -c -',' 'a' -a -f ''" \
	" -b ' xyz ' -e 'f' -c -',' 'a' -a -f '' --" \
	" -b ' xyz ' -e 'f' -c -',' 'a' -a -f '' --" \
	" -b ' xyz ' -e 'f' -c -',' 'a' -a -f '' --" \
	-b' xyz ' -ef -c,a -af

__test_section__ 'With "=" as a short option'
test_get_options_success \
	'ab:cd:=::f::' \
	'' \
	" -b ' xyz ' -f '' -c -'=' 'xyz' -d '-a'" \
	" -b ' xyz ' -f '' -c -'=' 'xyz' -d '-a' --" \
	" -b ' xyz ' -f '' -c -'=' 'xyz' -d '-a' --" \
	" -b ' xyz ' -f '' -c -'=' 'xyz' -d '-a' --" \
	-b ' xyz ' -f -c -=xyz -d -a

__test_section__ 'With "=" in merged options'
test_get_options_success \
	'ab:c=:e::f::' \
	'' \
	" -b ' xyz ' -e 'f' -c -'=' 'a' -a -f ''" \
	" -b ' xyz ' -e 'f' -c -'=' 'a' -a -f '' --" \
	" -b ' xyz ' -e 'f' -c -'=' 'a' -a -f '' --" \
	" -b ' xyz ' -e 'f' -c -'=' 'a' -a -f '' --" \
	-b' xyz ' -ef -c=a -af
