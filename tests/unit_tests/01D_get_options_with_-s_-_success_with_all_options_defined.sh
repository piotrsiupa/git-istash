. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE
PARAMETRIZE_GET_OPTIONS_SINGLE_DEFINITION 'SINGLE-DEF'

__end_of_initialization__

__test_section__ 'Without non-option arguments'
test_get_options_success \
	'a,anger,b:,bloodlust:,c,cruelty,d:,depravity:,e::,evilness::,f::,fury::' \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x'" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' --" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' --" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' --" \
	-c --depr=xyz -e --evil --anger -dx

__test_section__ 'With non-option arguments at the end (without separator)'
test_get_options_success \
	'a,anger,b:,bloodlust:,c,cruelty,d:,depravity:,e::,evilness::,f::,fury::' \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' 'qwerty' 'asdfgh' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' -- 'qwerty' 'asdfgh' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' -- 'qwerty' 'asdfgh' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' -- 'qwerty' 'asdfgh' 'zxcvbn'" \
	-c --depr=xyz -e --evil --anger -dx 'qwerty' 'asdfgh' 'zxcvbn'

__test_section__ 'With non-option arguments at the end (with separator)'
test_get_options_success \
	'a,anger,b:,bloodlust:,c,cruelty,d:,depravity:,e::,evilness::,f::,fury::' \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' '--' 'qwerty' 'asdfgh' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' -- 'qwerty' 'asdfgh' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' -- 'qwerty' 'asdfgh' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' -- '--' 'qwerty' 'asdfgh' 'zxcvbn'" \
	-c --depr=xyz -e --evil --anger -dx -- 'qwerty' 'asdfgh' 'zxcvbn'

__test_section__ 'With non-option arguments mixed in'
test_get_options_success \
	'a,anger,b:,bloodlust:,c,cruelty,d:,depravity:,e::,evilness::,f::,fury::' \
	" -c --depravity 'xyz' -e '' 'qwerty' --evilness '' --anger 'asdfgh' -d 'x' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' -- 'qwerty' 'asdfgh' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' -- 'qwerty' '--evil' '--anger' 'asdfgh' '-dx' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' -- 'qwerty' 'asdfgh' 'zxcvbn'" \
	-c --depr=xyz -e 'qwerty' --evil --anger 'asdfgh' -dx 'zxcvbn'

__test_section__ 'With non-option arguments mixed in and a random separator'
test_get_options_success \
	'a,anger,b:,bloodlust:,c,cruelty,d:,depravity:,e::,evilness::,f::,fury::' \
	" -c --depravity 'xyz' -e '' 'qwerty' --evilness '' '--' '--anger' 'asdfgh' '-dx' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' -- 'qwerty' '--anger' 'asdfgh' '-dx' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' -- 'qwerty' '--evil' '--' '--anger' 'asdfgh' '-dx' 'zxcvbn'" \
	" -c --depravity 'xyz' -e '' --evilness '' -- 'qwerty' '--' '--anger' 'asdfgh' '-dx' 'zxcvbn'" \
	-c --depr=xyz -e 'qwerty' --evil -- --anger 'asdfgh' -dx 'zxcvbn'
