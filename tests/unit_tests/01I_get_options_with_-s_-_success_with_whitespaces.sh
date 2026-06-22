# You're asking why someone would even bother to support this. I'm asking why not.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE
PARAMETRIZE_GET_OPTIONS_SINGLE_DEFINITION 'SINGLE-DEF'

__end_of_initialization__

if ! IS_WHITESPACE_STRIPPING_ON
then
	
	__test_section__ 'White short options'
	test_get_options_success \
		"a,anger,b:,bloodlust:,$tab:,cruelty,depravity:,$nl::,evilness::,f::,fury::, " \
		" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\\\t 'x'" \
		" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\\\t 'x' --" \
		" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\\\t 'x' --" \
		" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\\\t 'x' --" \
		-\  --depr=xyz -"$nl" --evil --anger -"$tab"x
	
	__test_section__ 'Whitespace in middle of long options'
	test_get_options_success \
		"a,ange${nl}r,b:,bloodlust:,c,cruelty,d:,d epravity:,e::,evi${tab}lness::,f::,fury::" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x'" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		-c --d\ epr=xyz -e --evi"$tab"l --ange"$nl"r -dx
	
	__test_section__ 'Whitespace at edges of long options'
	test_get_options_success \
		"a,       anger,b:,bloodlust:,c,cruelty,d:,depravity$tab:,f::,fury::,e::,${nl}evilness$nl::" \
		" -c --depravity\\\\\\t 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x'" \
		" -c --depravity\\\\\\t 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x' --" \
		" -c --depravity\\\\\\t 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x' --" \
		" -c --depravity\\\\\\t 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x' --" \
		-c --depr=xyz -e --"${nl}"evil --\ \ \ \ \ \ \ anger -dx
	
	__test_section__ 'Whitespace-only long options'
	test_get_options_success \
		"b:,bloodlust:,c,cruelty,d:,   :,a,$nl$nl$nl::,f::,fury::,e::,$tab$tab$tab" \
		" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\\\t\\\\\\t\\\\\\t -d 'x'" \
		" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\\\t\\\\\\t\\\\\\t -d 'x' --" \
		" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\\\t\\\\\\t\\\\\\t -d 'x' --" \
		" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\\\t\\\\\\t\\\\\\t -d 'x' --" \
		-c --\ \ =xyz -e --"$nl$nl$nl" --"$tab" -dx
	
else
	
	__test_section__ 'Whitespace in middle of long options'
	test_get_options_success \
		"a,ange${nl}r,b:,bloodlust:,c,cruelty,d:,d epravity:,e::,evi${tab}lness::,f::,fury::" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x'" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		-c --d\ epr=xyz -e --evi"$tab"l --ange"$nl"r -dx
	
	__test_section__ 'Whitespace at edges of options'
	test_get_options_success \
		'	a,
			anger,b:,bloodlust:,c,cruelty,d          :,depravity	:,f::,fury::,
			e
			::,evilness
			::' \
		" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x'" \
		" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' --" \
		" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' --" \
		" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' --" \
		-c --depr=xyz -e --evil --anger -dx
	if ! IS_PARTIAL_PARSE_ON
	then
		assert_exit_code 1 run_get_options \
			'	a,
				anger,b:,bloodlust:,c,cruelty,d          :,depravity	:,f::,fury::,
				e
				::,evilness
				::' \
			-c --depr=xyz -e --"${nl}evil" --\ \ \ \ \ \ \ anger -dx
		assert_outputs '.*' 'error: unknown option `\nevil'\'
	else
		test_get_options_success \
			'	a,
				anger,b:,bloodlust:,c,cruelty,d          :,depravity	:,f::,fury::,
				e
				::,evilness
				::' \
			"N/A" \
			"N/A" \
			"N/A" \
			" -c --depravity 'xyz' -e '' -- '--\nevil' '--       anger' '-dx'" \
			-c --depr=xyz -e --"${nl}evil" --\ \ \ \ \ \ \ anger -dx
	fi
	
	__test_section__ 'Whitespace-only options'
	assert_exit_code 2 run_get_options \
		"b:,bloodlust:,c,cruelty,d:,   :,a,$nl$nl$nl::,f::,fury::,e::,${tab}${tab}${tab}" \
		-c --\ \ =xyz -e --"$nl$nl$nl" --"$tab" -dx
	assert_outputs '' 'fatal: empty entry in options definition for get_options'
	
fi
