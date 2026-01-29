. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE 'PARTIAL_PARSE'

__end_of_initialization__

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

# Only short option requires additional tests like this.

__test_section__ 'With whitespaces'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c -- '-q  dd	d\\n'" \
	-cq'  dd	d
'

__test_section__ 'With whitespaces and even more line breaks'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c -- '-q  d\\nd	d\\n'" \
	-cq'  d
d	d
'

__test_section__ 'With WTF arguments'
wtf_string='bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
escaped_wtf_string='bo	=ÿþ€\{b\}\\\*\?#@!\[1;35;4;5m\|:<>\(\)\^&\[0mðŸ’©th'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c -- '-qddd$escaped_wtf_string'" \
	-cq"ddd$wtf_string"
