. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_GET_OPTIONS_MODE 'PARTIAL_PARSE'
PARAMETRIZE_GET_OPTIONS_CALL_STYLE

__end_of_initialization__

__test_section__ 'With unknown short option'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -- '-q' '--anger' '-dx'" \
	-c --depr=xyz -q --anger -dx

__test_section__ 'With unknown short option followed by known short option'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -- '-qabval' '--anger' '-dx'" \
	-c --depr=xyz -qabval --anger -dx

__test_section__ 'With unknown short option preceeded by known short option'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -a -c -- '-q' '--anger' '-dx'" \
	-c --depr=xyz -acq --anger -dx

__test_section__ 'With unknown long option'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -- '--quux' '--anger' '-dx'" \
	-c --depr=xyz --quux --anger -dx

__test_section__ 'With unknown long option with argument'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	"N/A" \
	"N/A" \
	"N/A" \
	" -c --depravity 'xyz' -- '--quux=baz' '--anger' '-dx'" \
	-c --depr=xyz --quux=baz --anger -dx
