# BE VERY CAREFULL EDITING THIS FILE!
# There is a good chance your editor will mangle the characters used here.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE 'PARTIAL_PARSE'
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE
PARAMETRIZE_GET_OPTIONS_SINGLE_DEFINITION 'SINGLE-DEF'

__end_of_initialization__

# Only short option requires additional tests like this.

__test_section__ 'With whitespaces'
test_get_options_success \
	'a,anger,b:,bloodlust:,c,cruelty,d:,depravity:,e::,evilness::,f::,fury::' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c -- '-q  dd\\td\\n'" \
	-cq"  dd${tab}d$nl"

__test_section__ 'With whitespaces and even more line breaks'
test_get_options_success \
	'a,anger,b:,bloodlust:,c,cruelty,d:,depravity:,e::,evilness::,f::,fury::' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c -- '-q  d\\nd\\td\\n'" \
	-cq"  d${nl}d${tab}d$nl"

__test_section__ 'With WTF arguments'
wtf_string='bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
escaped_wtf_string='bo	=ÿþ€\{b\}\\\*\?#@!\[1;35;4;5m\|:<>\(\)\^&\[0mðŸ’©th'
test_get_options_success \
	'a,anger,b:,bloodlust:,c,cruelty,d:,depravity:,e::,evilness::,f::,fury::' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c -- '-qddd$escaped_wtf_string'" \
	-cq"ddd$wtf_string"
