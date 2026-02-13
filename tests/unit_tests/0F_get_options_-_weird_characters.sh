. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE

__end_of_initialization__

__test_section__ 'With whitespaces'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	" '  aa	a\\n' --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' '  dd	d\\n' -d '  ee	e\\n' --cruelty --depravity '  ff	f\\n' '--' '-b  gg	g\\n'" \
	" --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' -d '  ee	e\\n' --cruelty --depravity '  ff	f\\n' -- '  aa	a\\n' '  dd	d\\n' '-b  gg	g\\n'" \
	" -- '  aa	a\\n' '--anger' '-b  bb	b\\n' '-c' '--bloodlust=  cc	c\\n' '  dd	d\\n' '-d' '  ee	e\\n' '--cruelty' '--depravity' '  ff	f\\n' '--' '-b  gg	g\\n'" \
	" --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' -d '  ee	e\\n' --cruelty --depravity '  ff	f\\n' -- '  aa	a\\n' '  dd	d\\n' '--' '-b  gg	g\\n'" \
	'  aa	a
' --anger -b'  bb	b
' -c --bloodlust='  cc	c
' '  dd	d
' -d '  ee	e
' --cruelty --depravity '  ff	f
' -- '-b  gg	g
'

__test_section__ 'With whitespaces and even more line breaks'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	" '  a\\na	a\\n' --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' '  d\\nd	d\\n' -d '  e\\ne	e\\n' --cruelty --depravity '  f\\nf	f\\n' '--' '-b  g\\ng	g\\n'" \
	" --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' -d '  e\\ne	e\\n' --cruelty --depravity '  f\\nf	f\\n' -- '  a\\na	a\\n' '  d\\nd	d\\n' '-b  g\\ng	g\\n'" \
	" -- '  a\\na	a\\n' '--anger' '-b  b\\nb	b\\n' '-c' '--bloodlust=  c\\nc	c\\n' '  d\\nd	d\\n' '-d' '  e\\ne	e\\n' '--cruelty' '--depravity' '  f\\nf	f\\n' '--' '-b  g\\ng	g\\n'" \
	" --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' -d '  e\\ne	e\\n' --cruelty --depravity '  f\\nf	f\\n' -- '  a\\na	a\\n' '  d\\nd	d\\n' '--' '-b  g\\ng	g\\n'" \
	'  a
a	a
' --anger -b'  b
b	b
' -c --bloodlust='  c
c	c
' '  d
d	d
' -d '  e
e	e
' --cruelty --depravity '  f
f	f
' -- '-b  g
g	g
'

__test_section__ 'With "=" in the second line'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	" 'a\\na=a' --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' 'd\\nd=d' -d 'e\\ne=e' --cruelty --depravity 'f\\nf=f' '--' '-bg\\ng=g'" \
	" --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -d 'e\\ne=e' --cruelty --depravity 'f\\nf=f' -- 'a\\na=a' 'd\\nd=d' '-bg\\ng=g'" \
	" -- 'a\\na=a' '--anger' '-bb\\nb=b' '-c' '--bloodlust=c\\nc=c' 'd\\nd=d' '-d' 'e\\ne=e' '--cruelty' '--depravity' 'f\\nf=f' '--' '-bg\\ng=g'" \
	" --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -d 'e\\ne=e' --cruelty --depravity 'f\\nf=f' -- 'a\\na=a' 'd\\nd=d' '--' '-bg\\ng=g'" \
	'a
a=a' --anger -b'b
b=b' -c --bloodlust='c
c=c' 'd
d=d' -d 'e
e=e' --cruelty --depravity 'f
f=f' -- '-bg
g=g'

__test_section__ 'With WTF arguments'
wtf_string='bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
escaped_wtf_string='bo	=ÿþ€\{b\}\\\*\?#@!\[1;35;4;5m\|:<>\(\)\^&\[0mðŸ’©th'
test_get_options_success \
	'ab:cd:' \
	'anger,bloodlust:,cruelty,depravity:' \
	" 'aaa$escaped_wtf_string' --anger -b 'bbb$escaped_wtf_string' -c --bloodlust 'ccc$escaped_wtf_string' 'ddd$escaped_wtf_string' -d 'eee$escaped_wtf_string' --cruelty --depravity 'fff$escaped_wtf_string' '--' '-bggg$escaped_wtf_string' 'Well, that was something, wasn'\\\\''t it\\?'" \
	" --anger -b 'bbb$escaped_wtf_string' -c --bloodlust 'ccc$escaped_wtf_string' -d 'eee$escaped_wtf_string' --cruelty --depravity 'fff$escaped_wtf_string' -- 'aaa$escaped_wtf_string' 'ddd$escaped_wtf_string' '-bggg$escaped_wtf_string' 'Well, that was something, wasn'\\\\''t it\\?'" \
	" -- 'aaa$escaped_wtf_string' '--anger' '-bbbb$escaped_wtf_string' '-c' '--bloodlust=ccc$escaped_wtf_string' 'ddd$escaped_wtf_string' '-d' 'eee$escaped_wtf_string' '--cruelty' '--depravity' 'fff$escaped_wtf_string' '--' '-bggg$escaped_wtf_string' 'Well, that was something, wasn'\\\\''t it\\?'" \
	" --anger -b 'bbb$escaped_wtf_string' -c --bloodlust 'ccc$escaped_wtf_string' -d 'eee$escaped_wtf_string' --cruelty --depravity 'fff$escaped_wtf_string' -- 'aaa$escaped_wtf_string' 'ddd$escaped_wtf_string' '--' '-bggg$escaped_wtf_string' 'Well, that was something, wasn'\\\\''t it\\?'" \
	"aaa$wtf_string" --anger -b"bbb$wtf_string" -c --bloodlust="ccc$wtf_string" "ddd$wtf_string" -d "eee$wtf_string" --cruelty --depravity "fff$wtf_string" -- "-bggg$wtf_string" 'Well, that was something, wasn'\''t it?'
