. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'set_color_for_all_and_check.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
set_color_for_all "\$1"
# Checking only one variable. The rest are covered by setting-specific tests.
git config --get-colorbool 'color.istash.error' 'true'
git config --get-colorbool 'color.istash.error' 'false'
EOF
chmod +x 'set_color_for_all_and_check.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./


git config set --local 'color.foo' 'never'


__test_section__ 'auto'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'auto'
assert_outputs 'true\nfalse' ''

__test_section__ 'default'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'default'
assert_outputs 'true\nfalse' ''

__test_section__ 'd'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'd'
assert_outputs 'true\nfalse' ''

__test_section__ 'terminal'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'terminal'
assert_outputs 'true\nfalse' ''

__test_section__ 'tty'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'tty'
assert_outputs 'true\nfalse' ''

__test_section__ 'terminal-only'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'terminal-only'
assert_outputs 'true\nfalse' ''

__test_section__ 'tty-only'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'tty-only'
assert_outputs 'true\nfalse' ''

__test_section__ 'magic'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'magic'
assert_outputs 'true\nfalse' ''


__test_section__ 'AUTO'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'AUTO'
assert_outputs 'true\nfalse' ''

__test_section__ 'DEFAULT'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'DEFAULT'
assert_outputs 'true\nfalse' ''

__test_section__ 'D'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'D'
assert_outputs 'true\nfalse' ''

__test_section__ 'TERMINAL'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'TERMINAL'
assert_outputs 'true\nfalse' ''

__test_section__ 'TTY'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'TTY'
assert_outputs 'true\nfalse' ''

__test_section__ 'TERMINAL-ONLY'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'TERMINAL-ONLY'
assert_outputs 'true\nfalse' ''

__test_section__ 'TTY-ONLY'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'TTY-ONLY'
assert_outputs 'true\nfalse' ''

__test_section__ 'MAGIC'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'MAGIC'
assert_outputs 'true\nfalse' ''
