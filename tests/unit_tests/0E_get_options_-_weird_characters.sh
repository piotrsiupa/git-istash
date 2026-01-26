. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE 'MODE' 'options' 'DEFAULT' 'NO_REORDER'

__end_of_initialization__

case "$MODE" in
	NO_REORDER) MODE_FLAGS='-R' ;;
	*) MODE_FLAGS='' ;;
esac

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'With whitespaces'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' '  aa	a
' --anger -b'  bb	b
' -c --bloodlust='  cc	c
' '  dd	d
' -d '  ee	e
' --cruelty --depravity '  ff	f
' -- '-b  gg	g
'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" '  aa	a\\n' --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' '  dd	d\\n' -d '  ee	e\\n' --cruelty --depravity '  ff	f\\n' '--' '-b  gg	g\\n'"
else
	expected_stdout=" --anger -b '  bb	b\\n' -c --bloodlust '  cc	c\\n' -d '  ee	e\\n' --cruelty --depravity '  ff	f\\n' -- '  aa	a\\n' '  dd	d\\n' '-b  gg	g\\n'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With whitespaces and even more line breaks'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' '  a
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
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" '  a\\na	a\\n' --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' '  d\\nd	d\\n' -d '  e\\ne	e\\n' --cruelty --depravity '  f\\nf	f\\n' '--' '-b  g\\ng	g\\n'"
else
	expected_stdout=" --anger -b '  b\\nb	b\\n' -c --bloodlust '  c\\nc	c\\n' -d '  e\\ne	e\\n' --cruelty --depravity '  f\\nf	f\\n' -- '  a\\na	a\\n' '  d\\nd	d\\n' '-b  g\\ng	g\\n'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With "=" in the second line'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' 'a
a=a' --anger -b'b
b=b' -c --bloodlust='c
c=c' 'd
d=d' -d 'e
e=e' --cruelty --depravity 'f
f=f' -- '-bg
g=g'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" 'a\\na=a' --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' 'd\\nd=d' -d 'e\\ne=e' --cruelty --depravity 'f\\nf=f' '--' '-bg\\ng=g'"
else
	expected_stdout=" --anger -b 'b\\nb=b' -c --bloodlust 'c\\nc=c' -d 'e\\ne=e' --cruelty --depravity 'f\\nf=f' -- 'a\\na=a' 'd\\nd=d' '-bg\\ng=g'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

wtf_string='bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
__test_section__ 'With WTF arguments'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:'  "aaa$wtf_string" --anger -b"bbb$wtf_string" -c --bloodlust="ccc$wtf_string" "ddd$wtf_string" -d "eee$wtf_string" --cruelty --depravity "fff$wtf_string" -- "-bggg$wtf_string" 'Well, that was something, wasn'\''t it?'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" 'aaa$wtf_string' --anger -b 'bbb$wtf_string' -c --bloodlust 'ccc$wtf_string' 'ddd$wtf_string' -d 'eee$wtf_string' --cruelty --depravity 'fff$wtf_string' '--' '-bggg$wtf_string' 'Well, that was something, wasn'\''t it?'"
else
	expected_stdout=" --anger -b 'bbb$wtf_string' -c --bloodlust 'ccc$wtf_string' -d 'eee$wtf_string' --cruelty --depravity 'fff$wtf_string' -- 'aaa$wtf_string' 'ddd$wtf_string' '-bggg$wtf_string' 'Well, that was something, wasn'\''t it?'"
fi
test "$stdout" = "$expected_stdout" ||
	fail 'Expected stdout of "%s" to be:\n"%s"\nbut it is:\n"%s"!\n' "$last_command" "$expected_stdout" "$stdout"
test -z "$stderr" ||
	fail 'Expected stderr of "%s" to be empty but it is:\n"%s"!\n' "$last_command" "$stderr"
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' 'anger,bloodlust:,cruelty,depravity:' "$@"
test "$stdout" = "$expected_stdout" ||
	fail 'Expected stdout of "%s" to be:\n"%s"\nbut it is:\n"%s"!\n' "$last_command" "$expected_stdout" "$stdout"
test -z "$stderr" ||
	fail 'Expected stderr of "%s" to be empty but it is:\n"%s"!\n' "$last_command" "$stderr"
