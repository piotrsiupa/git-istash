. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE 'MODE' 'options' 'DEFAULT' 'NO_REORDER'

__end_of_initialization__

case "$MODE" in
	NO_REORDER) MODE_FLAGS='-R' ;;
	*) MODE_FLAGS='' ;;
esac

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'Without arguments'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' ''
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=""
else
	expected_stdout=" --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'Without only --'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' --
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" '--'"
else
	expected_stdout=" --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an argument'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' abcd
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" 'abcd'"
else
	expected_stdout=" -- 'abcd'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an option'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -a
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -a"
else
	expected_stdout=" -a --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an option with a parameter'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -b ' xyz '
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -b ' xyz '"
else
	expected_stdout=" -b ' xyz ' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an option with an empty parameter'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -b ''
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -b ''"
else
	expected_stdout=" -b '' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With a few options'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -b ' xyz ' -c -d -a
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -b ' xyz ' -c -d '-a'"
else
	expected_stdout=" -b ' xyz ' -c -d '-a' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With a few repeated options'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -b ' xyz ' -c -d-a -b qwerty -a -c
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -b ' xyz ' -c -d '-a' -b 'qwerty' -a -c"
else
	expected_stdout=" -b ' xyz ' -c -d '-a' -b 'qwerty' -a -c --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With a few merged options'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -b' xyz ' -cda
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -b ' xyz ' -c -d 'a'"
else
	expected_stdout=" -b ' xyz ' -c -d 'a' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With a few merged and repeated options'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -b' xyz ' -cda -acb' qwerty '
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty '"
else
	expected_stdout=" -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -cba abcd -da 'a b'\''c d' -a
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -c -b 'a' 'abcd' -d 'a' 'a b'\\\\''c d' -a"
else
	expected_stdout=" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and "--" before arguments'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -cba -da -a -- abcd 'a b'\''c d'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -c -b 'a' -d 'a' -a '--' 'abcd' 'a b'\\\\''c d'"
else
	expected_stdout=" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and "--" in middle of arguments'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -cba abcd -da -a -- 'a b'\''c d'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -c -b 'a' 'abcd' -d 'a' -a '--' 'a b'\\\\''c d'"
else
	expected_stdout=" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and "--" after arguments'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -cba abcd -da 'a b'\''c d' -a --
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -c -b 'a' 'abcd' -d 'a' 'a b'\\\\''c d' -a '--'"
else
	expected_stdout=" -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and things looking like options after "--"'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -cba abcd -da -- -a 'a b'\''c d' -das\'\\dfg' '
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -c -b 'a' 'abcd' -d 'a' '--' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '"
else
	expected_stdout=" -c -b 'a' -d 'a' -- 'abcd' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and a few "--"'
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' -cba abcd -- -da -- -a 'a b'\''c d' -dasdfg --
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" -c -b 'a' 'abcd' '--' '-da' '--' '-a' 'a b'\\\\''c d' '-dasdfg' '--'"
else
	expected_stdout=" -c -b 'a' -- 'abcd' '-da' '--' '-a' 'a b'\\\\''c d' '-dasdfg' '--'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS 'ab:cd:' '' "$@"
assert_outputs "$expected_stdout" ''
