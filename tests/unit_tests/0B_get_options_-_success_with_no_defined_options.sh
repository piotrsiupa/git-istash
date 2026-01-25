. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

__end_of_initialization__

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'Without arguments'
assert_exit_code 0 get_options '' ''
assert_outputs " --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " --" ''

__test_section__ 'Without only --'
assert_exit_code 0 get_options '' '' --
assert_outputs " --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " --" ''

__test_section__ 'With an argument'
assert_exit_code 0 get_options '' '' abcd
assert_outputs " -- 'abcd'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " -- 'abcd'" ''

__test_section__ 'With an empty argument'
assert_exit_code 0 get_options '' '' ''
assert_outputs " -- ''" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " -- ''" ''

__test_section__ 'With some arguments'
assert_exit_code 0 get_options '' '' abcd 'a b'\''c d'
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With "--" before arguments'
assert_exit_code 0 get_options '' '' -- abcd 'a b'\''c d'
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With "--" in middle of arguments'
assert_exit_code 0 get_options '' '' abcd -- 'a b'\''c d'
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With "--" after arguments'
assert_exit_code 0 get_options '' '' abcd 'a b'\''c d' --
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With thinks looking like options after "--"'
assert_exit_code 0 get_options '' '' abcd 'a b'\''c d' -- -abcd --abcd
assert_outputs " -- 'abcd' 'a b'\\\\''c d' '-abcd' '--abcd'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " -- 'abcd' 'a b'\\\\''c d' '-abcd' '--abcd'" ''

__test_section__ 'With a few "--"'
assert_exit_code 0 get_options '' '' -- abcd -- 'a b'\''c d' --
assert_outputs " -- 'abcd' '--' 'a b'\\\\''c d' '--'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options '' '' "$@"
assert_outputs " -- 'abcd' '--' 'a b'\\\\''c d' '--'" ''
