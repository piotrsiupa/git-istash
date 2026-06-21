# BE VERY CAREFULL EDITING THIS FILE!
# There is a good chance your editor will mangle the characters used here.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE

__end_of_initialization__

__test_section__ 'With whitespaces'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" '  aa	a\\n' --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' -e '' --evilness '' '  dd	d\\n' -d '  ee	e\\n' --cruelty -f '  ff	f\\n' --fury '  gg	g\\n' --depravity '  hh	h\\n' '--' '-b  ii	i\\n'" \
	" --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' -e '' --evilness '' -d '  ee	e\\n' --cruelty -f '  ff	f\\n' --fury '  gg	g\\n' --depravity '  hh	h\\n' -- '  aa	a\\n' '  dd	d\\n' '-b  ii	i\\n'" \
	" -- '  aa	a\\n' '--anger' '-b  bb	b\\n' '-c' '--bloodlust=  cc	c\\n' '-e' '--evilness' '  dd	d\\n' '-d' '  ee	e\\n' '--cruelty' '-f  ff	f\\n' '--fury=  gg	g\\n' '--depravity' '  hh	h\\n' '--' '-b  ii	i\\n'" \
	" --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' -e '' --evilness '' -d '  ee	e\\n' --cruelty -f '  ff	f\\n' --fury '  gg	g\\n' --depravity '  hh	h\\n' -- '  aa	a\\n' '  dd	d\\n' '--' '-b  ii	i\\n'" \
	'  aa	a
' --anger -b'  bb	b
' -c --bloodlust='  cc	c
' -e --evilness '  dd	d
' -d '  ee	e
' --cruelty -f'  ff	f
' --fury='  gg	g
' --depravity '  hh	h
' -- '-b  ii	i
'

__test_section__ 'With whitespaces and even more line breaks'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" '  a\\na	a\\n' --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' -e '' --evilness '' '  d\\nd	d\\n' -d '  e\\ne	e\\n' --cruelty -f '  f\\nf	f\\n' --fury '  g\\ng	g\\n' --depravity '  h\\nh	h\\n' '--' '-b  i\\ni	i\\n'" \
	" --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' -e '' --evilness '' -d '  e\\ne	e\\n' --cruelty -f '  f\\nf	f\\n' --fury '  g\\ng	g\\n' --depravity '  h\\nh	h\\n' -- '  a\\na	a\\n' '  d\\nd	d\\n' '-b  i\\ni	i\\n'" \
	" -- '  a\\na	a\\n' '--anger' '-b  b\\nb	b\\n' '-c' '--bloodlust=  c\\nc	c\\n' '-e' '--evilness' '  d\\nd	d\\n' '-d' '  e\\ne	e\\n' '--cruelty' '-f  f\\nf	f\\n' '--fury=  g\\ng	g\\n' '--depravity' '  h\\nh	h\\n' '--' '-b  i\\ni	i\\n'" \
	" --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' -e '' --evilness '' -d '  e\\ne	e\\n' --cruelty -f '  f\\nf	f\\n' --fury '  g\\ng	g\\n' --depravity '  h\\nh	h\\n' -- '  a\\na	a\\n' '  d\\nd	d\\n' '--' '-b  i\\ni	i\\n'" \
	'  a
a	a
' --anger -b'  b
b	b
' -c --bloodlust='  c
c	c
' -e --evilness '  d
d	d
' -d '  e
e	e
' --cruelty -f'  f
f	f
' --fury='  g
g	g
' --depravity '  h
h	h
' -- '-b  i
i	i
'

__test_section__ 'With "=" in the second line'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" 'a\\na=a' --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -e '' --evilness '' 'd\\nd=d' -d 'e\\ne=e' --cruelty -f 'f\\nf=f' --fury 'g\\ng=g' --depravity 'h\\nh=h' '--' '-bi\\ni=i'" \
	" --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -e '' --evilness '' -d 'e\\ne=e' --cruelty -f 'f\\nf=f' --fury 'g\\ng=g' --depravity 'h\\nh=h' -- 'a\\na=a' 'd\\nd=d' '-bi\\ni=i'" \
	" -- 'a\\na=a' '--anger' '-bb\\nb=b' '-c' '--bloodlust=c\\nc=c' '-e' '--evilness' 'd\\nd=d' '-d' 'e\\ne=e' '--cruelty' '-ff\\nf=f' '--fury=g\\ng=g' '--depravity' 'h\\nh=h' '--' '-bi\\ni=i'" \
	" --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -e '' --evilness '' -d 'e\\ne=e' --cruelty -f 'f\\nf=f' --fury 'g\\ng=g' --depravity 'h\\nh=h' -- 'a\\na=a' 'd\\nd=d' '--' '-bi\\ni=i'" \
	'a
a=a' --anger -b'b
b=b' -c --bloodlust='c
c=c' -e --evilness 'd
d=d' -d 'e
e=e' --cruelty -f'f
f=f' --fury='g
g=g' --depravity 'h
h=h' -- '-bi
i=i'

__test_section__ 'With WTF arguments'
wtf_string='bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
escaped_wtf_string='bo	=ÿþ€\{b\}\\\*\?#@!\[1;35;4;5m\|:<>\(\)\^&\[0mðŸ’©th'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" 'aaa$escaped_wtf_string' --anger -b 'bbb$escaped_wtf_string' -c --bloodlust 'ccc$escaped_wtf_string' -e '' --evilness '' 'ddd$escaped_wtf_string' -d 'eee$escaped_wtf_string' --cruelty -f 'fff$escaped_wtf_string' --fury 'ggg$escaped_wtf_string' --depravity 'hhh$escaped_wtf_string' '--' '-biii$escaped_wtf_string' 'Well, that was something, wasn'\\\\''t it\\?'" \
	" --anger -b 'bbb$escaped_wtf_string' -c --bloodlust 'ccc$escaped_wtf_string' -e '' --evilness '' -d 'eee$escaped_wtf_string' --cruelty -f 'fff$escaped_wtf_string' --fury 'ggg$escaped_wtf_string' --depravity 'hhh$escaped_wtf_string' -- 'aaa$escaped_wtf_string' 'ddd$escaped_wtf_string' '-biii$escaped_wtf_string' 'Well, that was something, wasn'\\\\''t it\\?'" \
	" -- 'aaa$escaped_wtf_string' '--anger' '-bbbb$escaped_wtf_string' '-c' '--bloodlust=ccc$escaped_wtf_string' '-e' '--evilness' 'ddd$escaped_wtf_string' '-d' 'eee$escaped_wtf_string' '--cruelty' '-ffff$escaped_wtf_string' '--fury=ggg$escaped_wtf_string' '--depravity' 'hhh$escaped_wtf_string' '--' '-biii$escaped_wtf_string' 'Well, that was something, wasn'\\\\''t it\\?'" \
	" --anger -b 'bbb$escaped_wtf_string' -c --bloodlust 'ccc$escaped_wtf_string' -e '' --evilness '' -d 'eee$escaped_wtf_string' --cruelty -f 'fff$escaped_wtf_string' --fury 'ggg$escaped_wtf_string' --depravity 'hhh$escaped_wtf_string' -- 'aaa$escaped_wtf_string' 'ddd$escaped_wtf_string' '--' '-biii$escaped_wtf_string' 'Well, that was something, wasn'\\\\''t it\\?'" \
	"aaa$wtf_string" --anger -b"bbb$wtf_string" -c --bloodlust="ccc$wtf_string" -e --evilness "ddd$wtf_string" -d "eee$wtf_string" --cruelty -f"fff$wtf_string" --fury="ggg$wtf_string" --depravity "hhh$wtf_string" -- "-biii$wtf_string" 'Well, that was something, wasn'\''t it?'
