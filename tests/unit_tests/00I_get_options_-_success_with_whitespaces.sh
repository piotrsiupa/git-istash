# You're asking why someone would even bother to support this. I'm asking why not.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE

__end_of_initialization__

__test_section__ 'White short options'
test_get_options_success \
	'ab:	:
::f:: ' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\	 'x'" \
	" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\	 'x' --" \
	" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\	 'x' --" \
	" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\	 'x' --" \
	-\  --depr=xyz -'
' --evil --anger -\	x

__test_section__ 'Whitespace in middle of long options'
test_get_options_success \
	'ab:cd:e::f::' \
	'ange
r,bloodlust:,cruelty,d epravity:,evi	lness::,fury::' \
	" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\	lness '' --ange'\\n'r -d 'x'" \
	" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\	lness '' --ange'\\n'r -d 'x' --" \
	" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\	lness '' --ange'\\n'r -d 'x' --" \
	" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\	lness '' --ange'\\n'r -d 'x' --" \
	-c --d\ epr=xyz -e --evi\	l '--ange
r' -dx

__test_section__ 'Whitespace at edges of long options'
test_get_options_success \
	'ab:cd:e::f::' \
	'       anger,bloodlust:,cruelty,depravity	:,fury::,
evilness
::' \
	" -c --depravity\\\\	 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x'" \
	" -c --depravity\\\\	 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x' --" \
	" -c --depravity\\\\	 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x' --" \
	" -c --depravity\\\\	 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x' --" \
	-c --depr=xyz -e '--
evil' --\ \ \ \ \ \ \ anger -dx

__test_section__ 'Whitespace-only long options'
test_get_options_success \
	'ab:cd:e::f::' \
	'bloodlust:,cruelty,   :,


::,fury::,			' \
	" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\	\\\\	\\\\	 -d 'x'" \
	" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\	\\\\	\\\\	 -d 'x' --" \
	" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\	\\\\	\\\\	 -d 'x' --" \
	" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\	\\\\	\\\\	 -d 'x' --" \
	-c --\ \ =xyz -e --'


' --\	 -dx
