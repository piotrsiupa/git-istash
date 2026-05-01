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


__test_section__ 'always'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'always'
assert_outputs 'true\ntrue' ''

__test_section__ 'a'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'a'
assert_outputs 'true\ntrue' ''

__test_section__ 'yes'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'yes'
assert_outputs 'true\ntrue' ''

__test_section__ 'y'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'y'
assert_outputs 'true\ntrue' ''

__test_section__ 'true'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'true'
assert_outputs 'true\ntrue' ''

__test_section__ 't'
assert_exit_code 0 './set_color_for_all_and_check.sh' 't'
assert_outputs 'true\ntrue' ''

__test_section__ 'affirmative'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'affirmative'
assert_outputs 'true\ntrue' ''


__test_section__ 'ALWAYS'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'ALWAYS'
assert_outputs 'true\ntrue' ''

__test_section__ 'A'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'A'
assert_outputs 'true\ntrue' ''

__test_section__ 'YES'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'YES'
assert_outputs 'true\ntrue' ''

__test_section__ 'Y'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'Y'
assert_outputs 'true\ntrue' ''

__test_section__ 'TRUE'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'TRUE'
assert_outputs 'true\ntrue' ''

__test_section__ 'T'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'T'
assert_outputs 'true\ntrue' ''

__test_section__ 'AFFIRMATIVE'
assert_exit_code 0 './set_color_for_all_and_check.sh' 'AFFIRMATIVE'
assert_outputs 'true\ntrue' ''


__test_section__ '1'
assert_exit_code 0 './set_color_for_all_and_check.sh' '1'
assert_outputs 'true\ntrue' ''
