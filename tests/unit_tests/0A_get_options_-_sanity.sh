# Not sure if this is needed anymore. It was written mostly as a base for writing other tests.
# Whatever, it takes basically no time at all to run.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

__end_of_initialization__

__test_section__ 'Without option definitions and neither arguments'
assert_exit_code 0 getopt --long='' -n'error' -s'sh' -- ''
assert_outputs " --" ''
eval set -- "$stdout"
assert_exit_code 0 getopt --long='' -n'error' -s'sh' -- '' "$@"
assert_outputs " --" ''

__test_section__ 'Without option definitions but with arguments'
assert_exit_code 0 getopt --long='' -n'error' -s'sh' -- '' abcd 'a b'\''c d'
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 getopt --long='' -n'error' -s'sh' -- '' "$@"
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With option definitions but without arguments'
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b'
assert_outputs " --" ''
eval set -- "$stdout"
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b' "$@"
assert_outputs " --" ''

__test_section__ 'With option definitions and with non-option arguments'
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b' abcd 'a b'\''c d'
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b' "$@"
assert_outputs " -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With option definitions and with mixed arguments'
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b' --argh xxx abcd -baxy 'a b'\''c d' --bleh
assert_outputs " --argh 'xxx' -b -a 'xy' --bleh -- 'abcd' 'a b'\\\\''c d'" ''
eval set -- "$stdout"
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b' "$@"
assert_outputs " --argh 'xxx' -b -a 'xy' --bleh -- 'abcd' 'a b'\\\\''c d'" ''

__test_section__ 'With option definitions and with mixed arguments and "--"'
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b' --argh xxx -- abcd -baxy 'a b'\''c d' --bleh
assert_outputs " --argh 'xxx' -- 'abcd' '-baxy' 'a b'\\\\''c d' '--bleh'" ''
eval set -- "$stdout"
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b' "$@"
assert_outputs " --argh 'xxx' -- 'abcd' '-baxy' 'a b'\\\\''c d' '--bleh'" ''

__test_section__ 'With option definitions and with mixed arguments and a few "--"'
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b' --argh xxx -- abcd -baxy -- 'a b'\''c d' --bleh --
assert_outputs " --argh 'xxx' -- 'abcd' '-baxy' '--' 'a b'\\\\''c d' '--bleh' '--'" ''
eval set -- "$stdout"
assert_exit_code 0 getopt --long='argh:,bleh' -n'error' -s'sh' -- 'a:b' "$@"
assert_outputs " --argh 'xxx' -- 'abcd' '-baxy' '--' 'a b'\\\\''c d' '--bleh' '--'" ''
