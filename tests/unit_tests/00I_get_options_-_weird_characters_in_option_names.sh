# BE VERY CAREFULL EDITING THIS FILE!
# There is a good chance your editor will mangle the characters used here.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE

__end_of_initialization__

__test_section__ 'With WTF arguments'
wtf_string_start='bo'
wtf_string="$wtf_string_start"'ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
escaped_wtf_string="bo'''''''''''''''''ÿ''þ''''€''\{'b'\\}''\\\\''\\*''\\?''#''@''!''''\\['1';'35';'4';'5m'\\|'':''<''>''\\(''\\)''\\^''&''''\['0m'ð''Ÿ''’''©'th"
test_get_options_success \
	'ab:cd:::f::' \
	"anger,bloodlust:,cruelty,depravity:,$wtf_string::,fury::" \
	" -c --depravity 'xyz' --$escaped_wtf_string '' -'' '' 'qwerty' --$escaped_wtf_string 'wtf' '--' '--anger' 'asdfgh' '-dx' 'zxcvbn'" \
	" -c --depravity 'xyz' --$escaped_wtf_string '' -'' '' --$escaped_wtf_string 'wtf' -- 'qwerty' '--anger' 'asdfgh' '-dx' 'zxcvbn'" \
	" -c --depravity 'xyz' --$escaped_wtf_string '' -'' '' -- 'qwerty' '--$wtf_string_start=wtf' '--' '--anger' 'asdfgh' '-dx' 'zxcvbn'" \
	" -c --depravity 'xyz' --$escaped_wtf_string '' -'' '' --$escaped_wtf_string 'wtf' -- 'qwerty' '--' '--anger' 'asdfgh' '-dx' 'zxcvbn'" \
	-c --depr=xyz --"$wtf_string" -'' 'qwerty' --"$wtf_string_start"=wtf -- --anger 'asdfgh' -dx 'zxcvbn'
