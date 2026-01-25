. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

__end_of_initialization__

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'Without arguments'
assert_exit_code 0 get_options 'ab:cd:' ''
assert_outputs " --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " --" ''

__test_section__ 'Without only --'
assert_exit_code 0 get_options 'ab:cd:' '' --
assert_outputs " --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " --" ''

__test_section__ 'With an argument'
assert_exit_code 0 get_options 'ab:cd:' '' abcd
assert_outputs " -- 'abcd'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -- 'abcd'" ''

__test_section__ 'With an option'
assert_exit_code 0 get_options 'ab:cd:' '' -a
assert_outputs " -a --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -a --" ''

__test_section__ 'With an option with a parameter'
assert_exit_code 0 get_options 'ab:cd:' '' -b ' xyz '
assert_outputs " -b ' xyz ' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -b ' xyz ' --" ''

__test_section__ 'With an option with an empty parameter'
assert_exit_code 0 get_options 'ab:cd:' '' -b ''
assert_outputs " -b '' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -b '' --" ''

__test_section__ 'With a few options'
assert_exit_code 0 get_options 'ab:cd:' '' -b ' xyz ' -c -d -a
assert_outputs " -b ' xyz ' -c -d '-a' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -b ' xyz ' -c -d '-a' --" ''

__test_section__ 'With a few repeated options'
assert_exit_code 0 get_options 'ab:cd:' '' -b ' xyz ' -c -d-a -b qwerty -a -c
assert_outputs " -b ' xyz ' -c -d '-a' -b 'qwerty' -a -c --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -b ' xyz ' -c -d '-a' -b 'qwerty' -a -c --" ''

__test_section__ 'With a few merged options'
assert_exit_code 0 get_options 'ab:cd:' '' -b' xyz ' -cda
assert_outputs " -b ' xyz ' -c -d 'a' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -b ' xyz ' -c -d 'a' --" ''

__test_section__ 'With a few merged and repeated options'
assert_exit_code 0 get_options 'ab:cd:' '' -b' xyz ' -cda -acb' qwerty '
assert_outputs " -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' --" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -b ' xyz ' -c -d 'a' -a -c -b ' qwerty ' --" ''

__test_section__ 'With some options and arguments'
assert_exit_code 0 get_options 'ab:cd:' '' -cba abcd -da 'a b'\''c d' -a
assert_outputs " -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With some options and arguments and "--" before arguments'
assert_exit_code 0 get_options 'ab:cd:' '' -cba -da -a -- abcd 'a b'\''c d'
assert_outputs " -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With some options and arguments and "--" in middle of arguments'
assert_exit_code 0 get_options 'ab:cd:' '' -cba abcd -da -a -- 'a b'\''c d'
assert_outputs " -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With some options and arguments and "--" after arguments'
assert_exit_code 0 get_options 'ab:cd:' '' -cba abcd -da 'a b'\''c d' -a --
assert_outputs " -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -c -b 'a' -d 'a' -a -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With some options and arguments and things looking like options after "--"'
assert_exit_code 0 get_options 'ab:cd:' '' -cba abcd -da -- -a 'a b'\''c d' -das\'\\dfg' '
assert_outputs " -c -b 'a' -d 'a' -- 'abcd' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -c -b 'a' -d 'a' -- 'abcd' '-a' 'a b'\\\\''c d' '-das'\\\\''\\\\dfg '" ''

__test_section__ 'With some options and arguments and a few "--"'
assert_exit_code 0 get_options 'ab:cd:' '' -cba abcd -- -da -- -a 'a b'\''c d' -dasdfg --
assert_outputs " -c -b 'a' -- 'abcd' '-da' '--' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" ''
eval set -- "$stdout"
assert_exit_code 0 get_options 'ab:cd:' '' "$@"
assert_outputs " -c -b 'a' -- 'abcd' '-da' '--' '-a' 'a b'\\\\''c d' '-dasdfg' '--'" ''
