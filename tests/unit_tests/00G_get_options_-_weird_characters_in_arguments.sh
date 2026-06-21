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
	" '  aa\\ta\\n' --anger -b '  bb\\tb\\n' -c --bloodlust '  cc\\tc\\n' -e '' --evilness '' '  dd\\td\\n' -d '  ee\\te\\n' --cruelty -f '  ff\\tf\\n' --fury '  gg\\tg\\n' --depravity '  hh\\th\\n' '--' '-b  ii\\ti\\n'" \
	" --anger -b '  bb\\tb\\n' -c --bloodlust '  cc\\tc\\n' -e '' --evilness '' -d '  ee\\te\\n' --cruelty -f '  ff\\tf\\n' --fury '  gg\\tg\\n' --depravity '  hh\\th\\n' -- '  aa\\ta\\n' '  dd\\td\\n' '-b  ii\\ti\\n'" \
	" -- '  aa\\ta\\n' '--anger' '-b  bb\\tb\\n' '-c' '--bloodlust=  cc\\tc\\n' '-e' '--evilness' '  dd\\td\\n' '-d' '  ee\\te\\n' '--cruelty' '-f  ff\\tf\\n' '--fury=  gg\\tg\\n' '--depravity' '  hh\\th\\n' '--' '-b  ii\\ti\\n'" \
	" --anger -b '  bb\\tb\\n' -c --bloodlust '  cc\\tc\\n' -e '' --evilness '' -d '  ee\\te\\n' --cruelty -f '  ff\\tf\\n' --fury '  gg\\tg\\n' --depravity '  hh\\th\\n' -- '  aa\\ta\\n' '  dd\\td\\n' '--' '-b  ii\\ti\\n'" \
	"  aa${tab}a$nl" --anger -b"  bb${tab}b$nl" -c --bloodlust="  cc${tab}c$nl" -e --evilness "  dd${tab}d$nl" -d "  ee${tab}e$nl" --cruelty -f"  ff${tab}f$nl" --fury="  gg${tab}g$nl" --depravity "  hh${tab}h$nl" -- "-b  ii${tab}i$nl"

__test_section__ 'With whitespaces and even more line breaks'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" '  a\\na\\ta\\n' --anger -b '  b\\nb\\tb\\n' -c --bloodlust '  c\\nc\\tc\\n' -e '' --evilness '' '  d\\nd\\td\\n' -d '  e\\ne\\te\\n' --cruelty -f '  f\\nf\\tf\\n' --fury '  g\\ng\\tg\\n' --depravity '  h\\nh\\th\\n' '--' '-b  i\\ni\\ti\\n'" \
	" --anger -b '  b\\nb\\tb\\n' -c --bloodlust '  c\\nc\\tc\\n' -e '' --evilness '' -d '  e\\ne\\te\\n' --cruelty -f '  f\\nf\\tf\\n' --fury '  g\\ng\\tg\\n' --depravity '  h\\nh\\th\\n' -- '  a\\na\\ta\\n' '  d\\nd\\td\\n' '-b  i\\ni\\ti\\n'" \
	" -- '  a\\na\\ta\\n' '--anger' '-b  b\\nb\\tb\\n' '-c' '--bloodlust=  c\\nc\\tc\\n' '-e' '--evilness' '  d\\nd\\td\\n' '-d' '  e\\ne\\te\\n' '--cruelty' '-f  f\\nf\\tf\\n' '--fury=  g\\ng\\tg\\n' '--depravity' '  h\\nh\\th\\n' '--' '-b  i\\ni\\ti\\n'" \
	" --anger -b '  b\\nb\\tb\\n' -c --bloodlust '  c\\nc\\tc\\n' -e '' --evilness '' -d '  e\\ne\\te\\n' --cruelty -f '  f\\nf\\tf\\n' --fury '  g\\ng\\tg\\n' --depravity '  h\\nh\\th\\n' -- '  a\\na\\ta\\n' '  d\\nd\\td\\n' '--' '-b  i\\ni\\ti\\n'" \
	"  a${nl}a${tab}a$nl" --anger -b"  b${nl}b${tab}b$nl" -c --bloodlust="  c${nl}c${tab}c$nl" -e --evilness "  d${nl}d${tab}d$nl" -d "  e${nl}e${tab}e$nl" --cruelty -f"  f${nl}f${tab}f$nl" --fury="  g${nl}g${tab}g$nl" --depravity "  h${nl}h${tab}h$nl" -- "-b  i${nl}i${tab}i$nl"

__test_section__ 'With "=" in the second line'
test_get_options_success \
	'ab:cd:e::f::' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" 'a\\na=a' --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -e '' --evilness '' 'd\\nd=d' -d 'e\\ne=e' --cruelty -f 'f\\nf=f' --fury 'g\\ng=g' --depravity 'h\\nh=h' '--' '-bi\\ni=i'" \
	" --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -e '' --evilness '' -d 'e\\ne=e' --cruelty -f 'f\\nf=f' --fury 'g\\ng=g' --depravity 'h\\nh=h' -- 'a\\na=a' 'd\\nd=d' '-bi\\ni=i'" \
	" -- 'a\\na=a' '--anger' '-bb\\nb=b' '-c' '--bloodlust=c\\nc=c' '-e' '--evilness' 'd\\nd=d' '-d' 'e\\ne=e' '--cruelty' '-ff\\nf=f' '--fury=g\\ng=g' '--depravity' 'h\\nh=h' '--' '-bi\\ni=i'" \
	" --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -e '' --evilness '' -d 'e\\ne=e' --cruelty -f 'f\\nf=f' --fury 'g\\ng=g' --depravity 'h\\nh=h' -- 'a\\na=a' 'd\\nd=d' '--' '-bi\\ni=i'" \
	"a${nl}a=a" --anger -b"b${nl}b=b" -c --bloodlust="c${nl}c=c" -e --evilness "d${nl}d=d" -d "e${nl}e=e" --cruelty -f"f${nl}f=f" --fury="g${nl}g=g" --depravity "h${nl}h=h" -- "-bi${nl}i=i"

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
