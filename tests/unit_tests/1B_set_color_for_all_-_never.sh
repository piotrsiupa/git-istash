. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'set_color_for_all_and_check.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-commons'
set_color_for_all "\$1"
# Checking only one variable. The rest are covered by setting-specific tests.
git config --get-colorbool 'color.istash.error' 'true'
git config --get-colorbool 'color.istash.error' 'false'
EOF
chmod +x 'set_color_for_all_and_check.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./


git config --local 'color.foo' 'always'


__test_section__ 'never'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'never'
assert_outputs 'false\nfalse' ''

__test_section__ 'n'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'n'
assert_outputs 'false\nfalse' ''

__test_section__ 'no'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'no'
assert_outputs 'false\nfalse' ''

__test_section__ 'false'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'false'
assert_outputs 'false\nfalse' ''

__test_section__ 'f'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'f'
assert_outputs 'false\nfalse' ''

__test_section__ 'negative'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'negative'
assert_outputs 'false\nfalse' ''


__test_section__ 'NEVER'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'NEVER'
assert_outputs 'false\nfalse' ''

__test_section__ 'N'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'N'
assert_outputs 'false\nfalse' ''

__test_section__ 'NO'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'NO'
assert_outputs 'false\nfalse' ''

__test_section__ 'FALSE'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'FALSE'
assert_outputs 'false\nfalse' ''

__test_section__ 'F'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'F'
assert_outputs 'false\nfalse' ''

__test_section__ 'NEGATIVE'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'NEGATIVE'
assert_outputs 'false\nfalse' ''


__test_section__ '0'
assert_exit_code 0 './set_color_for_all_and_check.sh' '0'
assert_outputs 'false\nfalse' ''
