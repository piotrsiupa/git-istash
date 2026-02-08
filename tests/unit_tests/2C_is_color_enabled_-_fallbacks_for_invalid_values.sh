. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'is_color_enabled.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-commons'
is_color_enabled "\$@"
EOF
chmod +x 'is_color_enabled.sh'

git config --local 'color.wrong' 'tomato'

__test_section__ 'no arguments'
assert_exit_code__light 128 './is_color_enabled.sh'

__test_section__ 'single argument with a wrong value'
assert_exit_code__light 128 './is_color_enabled.sh' 'color.wrong'

__test_section__ 'one non-existing argument and one with a wrong value'
assert_exit_code__light 128 './is_color_enabled.sh' 'color.foo' 'color.wrong'

__test_section__ 'two non-existing arguments and one with a wrong value'
assert_exit_code__light 128 './is_color_enabled.sh' 'color.foo' 'color.bar' 'color.wrong'
