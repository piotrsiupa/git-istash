. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

__end_of_initialization__

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'Without arguments'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:'
assert_outputs " --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --" ''

__test_section__ 'Without only --'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --
assert_outputs " --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --" ''

__test_section__ 'With an argument'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' anger
assert_outputs " -- 'anger'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " -- 'anger'" ''

__test_section__ 'With an option'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --anger
assert_outputs " --anger --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --anger --" ''

__test_section__ 'With an option with a parameter'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust ' xyz '
assert_outputs " --bloodlust ' xyz ' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --bloodlust ' xyz ' --" ''

__test_section__ 'With an option with an empty parameter'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust ''
assert_outputs " --bloodlust '' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --bloodlust '' --" ''

__test_section__ 'With an option with a parameter separated by "="'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust=' xyz '
assert_outputs " --bloodlust ' xyz ' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --bloodlust ' xyz ' --" ''

__test_section__ 'With an option with an empty parameter separated by "="'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust=
assert_outputs " --bloodlust '' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --bloodlust '' --" ''

__test_section__ 'With a few options'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust ' xyz ' --cruelty --depravity=a
assert_outputs " --bloodlust ' xyz ' --cruelty --depravity 'a' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --bloodlust ' xyz ' --cruelty --depravity 'a' --" ''

__test_section__ 'With a few repeated options'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --bloodlust ' xyz ' --cruelty --depravity --anger --bloodlust qwerty --anger --cruelty
assert_outputs " --bloodlust ' xyz ' --cruelty --depravity '--anger' --bloodlust 'qwerty' --anger --cruelty --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --bloodlust ' xyz ' --cruelty --depravity '--anger' --bloodlust 'qwerty' --anger --cruelty --" ''

__test_section__ 'With a few abbreviated options'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --blood ' xyz ' --cruelt --d=a
assert_outputs " --bloodlust ' xyz ' --cruelty --depravity 'a' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --bloodlust ' xyz ' --cruelty --depravity 'a' --" ''

__test_section__ 'With a few abbreviation that is a name of a different option'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,blood,depravity:' --bloodl ' xyz ' --cruelt --blood --d=a
assert_outputs " --bloodlust ' xyz ' --cruelty --blood --depravity 'a' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,blood,depravity:' "$@"
assert_outputs " --bloodlust ' xyz ' --cruelty --blood --depravity 'a' --" ''

__test_section__ 'With some options and arguments'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --bl=a abcd --deprav a 'a b'\''c d' --anger
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With some options and arguments and "--" before arguments'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --bloodlust=a --depravity a --ang -- abcd 'a b'\''c d'
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With some options and arguments and "--" in middle of arguments'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --bloodlust=a abcd --depr a --anger -- 'a b'\''c d'
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With some options and arguments and "--" after arguments'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --bloo=a abcd --depravity a 'a b'\''c d' --an --
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With some options and arguments and things looking like options after "--"'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --cr --b=a abcd --depra a -- --anger 'a b'\''c d' --deprav as\'\\dfg' '
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' -- 'abcd' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --cruelty --bloodlust 'a' --depravity 'a' -- 'abcd' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '" ''

__test_section__ 'With some options and arguments and a few "--"'
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' --cruelty --blood=a abcd -- --d=a -- --ang 'a b'\''c d' --depravity asdfg --
assert_outputs " --cruelty --bloodlust 'a' -- 'abcd' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' 'anger,bloodlust:,cruelty,depravity:' "$@"
assert_outputs " --cruelty --bloodlust 'a' -- 'abcd' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'" ''
