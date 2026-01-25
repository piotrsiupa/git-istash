. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

__end_of_initialization__

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'With whitespaces'
assert_exit_code 0 get_options 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' '  aa	a
' --anger -b'  bb	b
' -c --bloodlust='  cc	c
' '  dd	d
' -d '  ee	e
' --cruelty --depravity '  ff	f
' -- '-b  gg	g
'
assert_outputs " --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' -d '  ee	e\\n' --cruelty --depravity '  ff	f\\n' -- '  aa	a\\n' '  dd	d\\n' '-b  gg	g\\n'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' -d '  ee	e\\n' --cruelty --depravity '  ff	f\\n' -- '  aa	a\\n' '  dd	d\\n' '-b  gg	g\\n'" ''

__test_section__ 'With whitespaces and even more line breaks'
assert_exit_code 0 get_options 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' '  a
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
assert_outputs " --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' -d '  e\\ne	e\\n' --cruelty --depravity '  f\\nf	f\\n' -- '  a\\na	a\\n' '  d\\nd	d\\n' '-b  g\\ng	g\\n'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' -d '  e\\ne	e\\n' --cruelty --depravity '  f\\nf	f\\n' -- '  a\\na	a\\n' '  d\\nd	d\\n' '-b  g\\ng	g\\n'" ''

__test_section__ 'With "=" in the second line'
assert_exit_code 0 get_options 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' 'a
a=a' --anger -b'b
b=b' -c --bloodlust='c
c=c' 'd
d=d' -d 'e
e=e' --cruelty --depravity 'f
f=f' -- '-bg
g=g'
assert_outputs " --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -d 'e\\ne=e' --cruelty --depravity 'f\\nf=f' -- 'a\\na=a' 'd\\nd=d' '-bg\\ng=g'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -d 'e\\ne=e' --cruelty --depravity 'f\\nf=f' -- 'a\\na=a' 'd\\nd=d' '-bg\\ng=g'" ''

wtf_string='bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
__test_section__ 'With WTF arguments'
assert_exit_code 0 get_options 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:'  "aaa$wtf_string" --anger -b"bbb$wtf_string" -c --bloodlust="ccc$wtf_string" "ddd$wtf_string" -d "eee$wtf_string" --cruelty --depravity "fff$wtf_string" -- "-bggg$wtf_string" 'Well, that was something, wasn'\''t it?'
expected_output=" --anger -b 'bbb$wtf_string' -c --bloodlust 'ccc$wtf_string' -d 'eee$wtf_string' --cruelty --depravity 'fff$wtf_string' -- 'aaa$wtf_string' 'ddd$wtf_string' '-bggg$wtf_string' 'Well, that was something, wasn'\''t it?'"
test "$stdout" = "$expected_output" ||
	fail 'Expected stdout of "%s" to be:\n"%s"\nbut it is:\n"%s"!\n' "$last_command" "$expected_output" "$stdout"
test -z "$stderr" ||
	fail 'Expected stderr of "%s" to be empty but it is:\n"%s"!\n' "$last_command" "$stderr"
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' "$@"
test "$stdout" = "$expected_output" ||
	fail 'Expected stdout of "%s" to be:\n"%s"\nbut it is:\n"%s"!\n' "$last_command" "$expected_output" "$stdout"
test -z "$stderr" ||
	fail 'Expected stderr of "%s" to be empty but it is:\n"%s"!\n' "$last_command" "$stderr"
