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
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=""
else
	expected_stdout=" --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'Without only --'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" '--'"
else
	expected_stdout=" --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an argument'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' anger
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" 'anger'"
else
	expected_stdout=" -- 'anger'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an option'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --anger
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --anger"
else
	expected_stdout=" --anger --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an option with a parameter'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust ' xyz '
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --bloodlust ' xyz '"
else
	expected_stdout=" --bloodlust ' xyz ' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an option with an empty parameter'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust ''
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --bloodlust ''"
else
	expected_stdout=" --bloodlust '' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an option with a parameter separated by "="'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust=' xyz '
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --bloodlust ' xyz '"
else
	expected_stdout=" --bloodlust ' xyz ' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With an option with an empty parameter separated by "="'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust=
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --bloodlust ''"
else
	expected_stdout=" --bloodlust '' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With a few options'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust ' xyz ' --cruelty --depravity=a
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --bloodlust ' xyz ' --cruelty --depravity 'a'"
else
	expected_stdout=" --bloodlust ' xyz ' --cruelty --depravity 'a' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With a few repeated options'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust ' xyz ' --cruelty --depravity --anger --bloodlust qwerty --anger --cruelty
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --bloodlust ' xyz ' --cruelty --depravity '--anger' --bloodlust 'qwerty' --anger --cruelty"
else
	expected_stdout=" --bloodlust ' xyz ' --cruelty --depravity '--anger' --bloodlust 'qwerty' --anger --cruelty --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With a few abbreviated options'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --blood ' xyz ' --cruelt --d=a
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --bloodlust ' xyz ' --cruelty --depravity 'a'"
else
	expected_stdout=" --bloodlust ' xyz ' --cruelty --depravity 'a' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With a few abbreviation that is a name of a different option'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,blood,depravity:' --bloodl ' xyz ' --cruelt --blood --d=a
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --bloodlust ' xyz ' --cruelty --blood --depravity 'a'"
else
	expected_stdout=" --bloodlust ' xyz ' --cruelty --blood --depravity 'a' --"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,blood,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --bl=a abcd --deprav a 'a b'\''c d' --anger
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --cruelty --bloodlust 'a' 'abcd' --depravity 'a' 'a b'\\\\''c d' --anger"
else
	expected_stdout=" --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and "--" before arguments'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --bloodlust=a --depravity a --ang -- abcd 'a b'\''c d'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --cruelty --bloodlust 'a' --depravity 'a' --anger '--' 'abcd' 'a b'\\\\''c d'"
else
	expected_stdout=" --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and "--" in middle of arguments'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --bloodlust=a abcd --depr a --anger -- 'a b'\''c d'
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --cruelty --bloodlust 'a' 'abcd' --depravity 'a' --anger '--' 'a b'\\\\''c d'"
else
	expected_stdout=" --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and "--" after arguments'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --bloo=a abcd --depravity a 'a b'\''c d' --an --
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --cruelty --bloodlust 'a' 'abcd' --depravity 'a' 'a b'\\\\''c d' --anger '--'"
else
	expected_stdout=" --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and things looking like options after "--"'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --cr --b=a abcd --depra a -- --anger 'a b'\''c d' --deprav as\'\\dfg' '
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --cruelty --bloodlust 'a' 'abcd' --depravity 'a' '--' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '"
else
	expected_stdout=" --cruelty --bloodlust 'a' --depravity 'a' -- 'abcd' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''

__test_section__ 'With some options and arguments and a few "--"'
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --blood=a abcd -- --d=a -- --ang 'a b'\''c d' --depravity asdfg --
if [ "$MODE" = 'NO_REORDER' ]
then
	expected_stdout=" --cruelty --bloodlust 'a' 'abcd' '--' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'"
else
	expected_stdout=" --cruelty --bloodlust 'a' -- 'abcd' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'"
fi
assert_outputs "$expected_stdout" ''
eval set -- "$stdout"
assert_exit_code 0 get_options $MODE_FLAGS '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs "$expected_stdout" ''
