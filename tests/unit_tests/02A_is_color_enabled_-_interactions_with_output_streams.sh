. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'is_color_enabled.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
is_color_enabled "\$@"
EOF
chmod +x 'is_color_enabled.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./


git config --local 'color.foo' 'never'

__test_section__ '"auto" with outputs attached to terminal'
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 1>/dev/tty 2>&1

__test_section__ '"auto" with only stdout attached to terminal'
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 1>/dev/tty 2>/dev/null

__test_section__ '"auto" with only stderr attached to terminal'
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 1>/dev/null 2>/dev/tty

__test_section__ '"auto" with no output attached to terminal'
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 1>/dev/null 2>&1


git config --local 'color.foo' 'auto'

__test_section__ '"auto" with outputs attached to terminal'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 1>/dev/tty 2>&1

__test_section__ '"auto" with only stdout attached to terminal'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 1>/dev/tty 2>/dev/null

__test_section__ '"auto" with only stderr attached to terminal'
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 1>/dev/null 2>/dev/tty

__test_section__ '"auto" with no output attached to terminal'
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 1>/dev/null 2>&1


git config --local 'color.foo' 'always'

__test_section__ '"auto" with outputs attached to terminal'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 1>/dev/tty 2>&1

__test_section__ '"auto" with only stdout attached to terminal'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 1>/dev/tty 2>/dev/null

__test_section__ '"auto" with only stderr attached to terminal'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 1>/dev/null 2>/dev/tty

__test_section__ '"auto" with no output attached to terminal'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 1>/dev/null 2>&1
