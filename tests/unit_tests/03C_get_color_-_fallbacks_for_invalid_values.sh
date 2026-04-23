. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'get_color.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
get_color "\$@"
EOF
chmod +x 'get_color.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

# Parsing colors won't be extensively tested because it's done by a Git function.
# This focuses on the fallback system and corner cases.

git config --local 'color.thebestcolor' 'bold cyan'
git config --local 'color.alittleworsecolor' 'green'
git config --local 'color.somethirdcolor' 'blue'
git config --local 'color.foo' 'qwerty'
git config --local 'color.bar' 'asdfgh'
git config --local 'color.baz' 'zxcvbn'


__test_section__ 'with default value and an existing variable'
assert_exit_code 0 './get_color.sh' 'color.thebestcolor' 'color.alittleworsecolor' 'red'
assert_outputs_with_color '\[1;36m' ''

__test_section__ 'with default value and a non-existing variable'
assert_exit_code 0 './get_color.sh' 'color.foo' 'color.alittleworsecolor' 'red'
assert_outputs_with_color '\[32m' "
	$(create_bad_color_config_value_regex 'qwerty' 'color.foo')
"


__test_section__ 'with default value and two existing variables'
assert_exit_code 0 './get_color.sh' 'color.thebestcolor' 'color.alittleworsecolor' 'red'
assert_outputs_with_color '\[1;36m' ''

__test_section__ 'with default value and good variables, first non-existing'
assert_exit_code 0 './get_color.sh' 'color.foo' 'color.alittleworsecolor' 'red'
assert_outputs_with_color '\[32m' "
	$(create_bad_color_config_value_regex 'qwerty' 'color.foo')
"

__test_section__ 'with default value and two variables, second non-existing'
assert_exit_code 0 './get_color.sh' 'color.thebestcolor' 'color.bar' 'red'
assert_outputs_with_color '\[1;36m' ''

__test_section__ 'with default value and two non-existing variables'
assert_exit_code 0 './get_color.sh' 'color.foo' 'color.bar' 'red'
assert_outputs_with_color '\[31m' "
	$(create_bad_color_config_value_regex 'qwerty' 'color.foo')\\n
	$(create_bad_color_config_value_regex 'asdfgh' 'color.bar')
"


__test_section__ 'with default value and three existing variables, variant 0'
assert_exit_code 0 './get_color.sh' 'color.thebestcolor' 'color.alittleworsecolor' 'color.somethirdcolor' 'red'
assert_outputs_with_color '\[1;36m' ''

__test_section__ 'with default value and three existing variables, variant 1'
assert_exit_code 0 './get_color.sh' 'color.foo' 'color.alittleworsecolor' 'color.somethirdcolor' 'red'
assert_outputs_with_color '\[32m' "
	$(create_bad_color_config_value_regex 'qwerty' 'color.foo')
"

__test_section__ 'with default value and three existing variables, variant 2'
assert_exit_code 0 './get_color.sh' 'color.thebestcolor' 'color.bar' 'color.somethirdcolor' 'red'
assert_outputs_with_color '\[1;36m' ''

__test_section__ 'with default value and three existing variables, variant 3'
assert_exit_code 0 './get_color.sh' 'color.foo' 'color.bar' 'color.somethirdcolor' 'red'
assert_outputs_with_color '\[34m' "
	$(create_bad_color_config_value_regex 'qwerty' 'color.foo')\\n
	$(create_bad_color_config_value_regex 'asdfgh' 'color.bar')
"

__test_section__ 'with default value and three existing variables, variant 4'
assert_exit_code 0 './get_color.sh' 'color.thebestcolor' 'color.alittleworsecolor' 'color.baz' 'red'
assert_outputs_with_color '\[1;36m' ''

__test_section__ 'with default value and three existing variables, variant 5'
assert_exit_code 0 './get_color.sh' 'color.foo' 'color.alittleworsecolor' 'color.baz' 'red'
assert_outputs_with_color '\[32m' "
	$(create_bad_color_config_value_regex 'qwerty' 'color.foo')
"

__test_section__ 'with default value and three existing variables, variant 6'
assert_exit_code 0 './get_color.sh' 'color.thebestcolor' 'color.bar' 'color.baz' 'red'
assert_outputs_with_color '\[1;36m' ''

__test_section__ 'with default value and three existing variables, variant 7'
assert_exit_code 0 './get_color.sh' 'color.foo' 'color.bar' 'color.baz' 'red'
assert_outputs_with_color '\[31m' "
	$(create_bad_color_config_value_regex 'qwerty' 'color.foo')\\n
	$(create_bad_color_config_value_regex 'asdfgh' 'color.bar')\\n
	$(create_bad_color_config_value_regex 'zxcvbn' 'color.baz')
"
