. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_GET_OPTIONS_MODE 'PARTIAL_PARSE'
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE

__end_of_initialization__

__test_section__ 'With unknown short option'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -e '' --evilness '' -- '-q' '--anger' '-dx'" \
	-c --depr=xyz -e --evil -q --anger -dx

__test_section__ 'With unknown short option followed by known short option'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -e '' --evilness '' -- '-qabval' '--anger' '-dx'" \
	-c --depr=xyz -e --evil -qabval --anger -dx

__test_section__ 'With unknown short option preceeded by known short option'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -e '' --evilness '' -a -c -- '-q' '--anger' '-dx'" \
	-c --depr=xyz -e --evil -acq --anger -dx

__test_section__ 'With unknown long option'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -e '' --evilness '' -- '--quux' '--anger' '-dx'" \
	-c --depr=xyz -e --evil --quux --anger -dx

__test_section__ 'With unknown long option with argument'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -e '' --evilness '' -- '--quux=baz' '--anger' '-dx'" \
	-c --depr=xyz -e --evil --quux=baz --anger -dx
