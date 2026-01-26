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
assert_exit_code 0 get_options $MODE_FLAGS '' ''
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=""
else
	expected_stdout=" --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'Without only --'
assert_exit_code 0 get_options $MODE_FLAGS '' '' --
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" '--'"
else
	expected_stdout=" --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an argument'
assert_exit_code 0 get_options $MODE_FLAGS '' '' abcd
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" 'abcd'"
else
	expected_stdout=" -- 'abcd'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an empty argument'
assert_exit_code 0 get_options $MODE_FLAGS '' '' ''
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" ''"
else
	expected_stdout=" -- ''"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some arguments'
assert_exit_code 0 get_options $MODE_FLAGS '' '' abcd 'a b'\''c d'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" 'abcd' 'a b'\\\\''c d'"
else
	expected_stdout=" -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With "--" before arguments'
assert_exit_code 0 get_options $MODE_FLAGS '' '' -- abcd 'a b'\''c d'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" '--' 'abcd' 'a b'\\\\''c d'"
else
	expected_stdout=" -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With "--" in middle of arguments'
assert_exit_code 0 get_options $MODE_FLAGS '' '' abcd -- 'a b'\''c d'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" 'abcd' '--' 'a b'\\\\''c d'"
else
	expected_stdout=" -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With "--" after arguments'
assert_exit_code 0 get_options $MODE_FLAGS '' '' abcd 'a b'\''c d' --
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" 'abcd' 'a b'\\\\''c d' '--'"
else
	expected_stdout=" -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With thinks looking like options after "--"'
assert_exit_code 0 get_options $MODE_FLAGS '' '' abcd 'a b'\''c d' -- -abcd --abcd
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" 'abcd' 'a b'\\\\''c d' '--' '-abcd' '--abcd'"
else
	expected_stdout=" -- 'abcd' 'a b'\\\\''c d' '-abcd' '--abcd'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With a few "--"'
assert_exit_code 0 get_options $MODE_FLAGS '' '' -- abcd -- 'a b'\''c d' --
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" '--' 'abcd' '--' 'a b'\\\\''c d' '--'"
else
	expected_stdout=" -- 'abcd' '--' 'a b'\\\\''c d' '--'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' '' "$@"
assert_outputs "$expected_stdout" ''
