# You're asking why someone would even bother to support this. I'm asking why not.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE

__end_of_initialization__

if ! IS_WHITESPACE_STRIPPING_ON
then
	
	__test_section__ 'White short options'
	test_get_options_success \
		"ab:$tab:$nl::f:: " \
		'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
		" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\\\t 'x'" \
		" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\\\t 'x' --" \
		" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\\\t 'x' --" \
		" -\\\\  --depravity 'xyz' -'\\n' '' --evilness '' --anger -\\\\\\t 'x' --" \
		-\  --depr=xyz -"$nl" --evil --anger -"$tab"x
	
	__test_section__ 'Whitespace in middle of long options'
	test_get_options_success \
		'ab:cd:e::f::' \
		"ange${nl}r,bloodlust:,cruelty,d epravity:,evi${tab}lness::,fury::" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x'" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		-c --d\ epr=xyz -e --evi"$tab"l --ange"$nl"r -dx
	
	__test_section__ 'Whitespace at edges of long options'
	test_get_options_success \
		'ab:cd:e::f::' \
		"       anger,bloodlust:,cruelty,depravity$tab:,fury::,${nl}evilness$nl::" \
		" -c --depravity\\\\\\t 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x'" \
		" -c --depravity\\\\\\t 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x' --" \
		" -c --depravity\\\\\\t 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x' --" \
		" -c --depravity\\\\\\t 'xyz' -e '' --'\\n'evilness'\\n' '' --\\\\ \\\\ \\\\ \\\\ \\\\ \\\\ \\\\ anger -d 'x' --" \
		-c --depr=xyz -e --"${nl}"evil --\ \ \ \ \ \ \ anger -dx
	
	__test_section__ 'Whitespace-only long options'
	test_get_options_success \
		'ab:cd:e::f::' \
		"bloodlust:,cruelty,   :,$nl$nl$nl::,fury::,$tab$tab$tab" \
		" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\\\t\\\\\\t\\\\\\t -d 'x'" \
		" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\\\t\\\\\\t\\\\\\t -d 'x' --" \
		" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\\\t\\\\\\t\\\\\\t -d 'x' --" \
		" -c --\\\\ \\\\ \\\\  'xyz' -e '' --'\\n''\\n''\\n' '' --\\\\\\t\\\\\\t\\\\\\t -d 'x' --" \
		-c --\ \ =xyz -e --"$nl$nl$nl" --"$tab" -dx
	
else
	
	__test_section__ 'White short options'
	test_get_options_success \
		' a	b:
			f:: ' \
		'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
		" -a --depravity 'xyz' -f '' --evilness '' --anger -b 'x'" \
		" -a --depravity 'xyz' -f '' --evilness '' --anger -b 'x' --" \
		" -a --depravity 'xyz' -f '' --evilness '' --anger -b 'x' --" \
		" -a --depravity 'xyz' -f '' --evilness '' --anger -b 'x' --" \
		-a --depr=xyz -f --evil --anger -bx
	if ! IS_PARTIAL_PARSE_ON
	then
		assert_exit_code 1 run_get_options \
			' a	b:
				f:: ' \
			'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
			-\  --depr=xyz -"$nl" --evil --anger -"$tab"x
		assert_outputs '.*' 'error: unknown switch ` '\'
	else
		test_get_options_success \
			' a	b:
				f:: ' \
			'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
			"N/A" \
			"N/A" \
			"N/A" \
			" -- '- ' '--depr=xyz' '-\n' '--evil' '--anger' '-\tx'" \
			-\  --depr=xyz -"$nl" --evil --anger -"$tab"x
	fi
	
	__test_section__ 'Whitespace in middle of long options'
	test_get_options_success \
		'ab:cd:e::f::' \
		"ange${nl}r,bloodlust:,cruelty,d epravity:,evi${tab}lness::,fury::" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x'" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		" -c --d\\\\ epravity 'xyz' -e '' --evi\\\\\\tlness '' --ange'\\n'r -d 'x' --" \
		-c --d\ epr=xyz -e --evi"$tab"l --ange"$nl"r -dx
	
	__test_section__ 'Whitespace at edges of long options'
	test_get_options_success \
		'ab:cd:e::f::' \
		'       anger,bloodlust:,cruelty,depravity	:,fury::,
			evilness
			::' \
		" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x'" \
		" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' --" \
		" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' --" \
		" -c --depravity 'xyz' -e '' --evilness '' --anger -d 'x' --" \
		-c --depr=xyz -e --evil --anger -dx
	if ! IS_PARTIAL_PARSE_ON
	then
		assert_exit_code 1 run_get_options \
			'ab:cd:e::f::' \
			'       anger,bloodlust:,cruelty,depravity	:,fury::,
				evilness
				::' \
			-c --depr=xyz -e --"${nl}evil" --\ \ \ \ \ \ \ anger -dx
		assert_outputs '.*' 'error: unknown option `\nevil'\'
	else
		test_get_options_success \
			'ab:cd:e::f::' \
			'       anger,bloodlust:,cruelty,depravity	:,fury::,
				evilness
				::' \
			"N/A" \
			"N/A" \
			"N/A" \
			" -c --depravity 'xyz' -e '' -- '--\nevil' '--       anger' '-dx'" \
			-c --depr=xyz -e --"${nl}evil" --\ \ \ \ \ \ \ anger -dx
	fi
	
	__test_section__ 'Whitespace-only long options'
	assert_exit_code 2 run_get_options \
		'ab:cd:e::f::' \
		"bloodlust:,cruelty,   :,$nl$nl$nl::,fury::,${tab}${tab}${tab}" \
		-c --\ \ =xyz -e --"$nl$nl$nl" --"$tab" -dx
	assert_outputs '' 'fatal: empty entry in long options definition for get_options'
	
fi
