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

git config --local 'color.wrong' 'tomato'
git config --local 'color.wrong2' 'potato'
git config --local 'color.doit' 'always'
git config --local 'color.nowait' 'never'

stdout=''

__test_section__ 'no arguments'
assert_exit_code__light 128 './is_color_enabled.sh' >/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' 'fatal: not enough arguments for is_color_enabled'
assert_exit_code__light 128 './is_color_enabled.sh' >/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' 'fatal: not enough arguments for is_color_enabled'

__test_section__ 'single wrong value'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.wrong' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.wrong' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"

__test_section__ 'two wrong values'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.wrong' 'color.wrong2' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.wrong' 'color.wrong2' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"

__test_section__ 'one non-existing value and one wrong value'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 'color.wrong' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 'color.wrong' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"

__test_section__ 'one non-existing value and one two wrong values'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 'color.wrong' 'color.wrong2' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 'color.wrong' 'color.wrong2' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"

__test_section__ 'two non-existing value and one wrong value'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 'color.bar' 'color.wrong' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 'color.bar' 'color.wrong' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"

__test_section__ 'two non-existing value and two wrong values'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 'color.bar' 'color.wrong' 'color.wrong2' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 'color.bar' 'color.wrong' 'color.wrong2' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"

__test_section__ 'two non-existing value and two wrong values (alternately)'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 'color.wrong' 'color.bar' 'color.wrong2' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 'color.wrong' 'color.bar' 'color.wrong2' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"

__test_section__ 'one with a wrong value and one correct value'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.wrong' 'color.doit' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"
assert_exit_code__light 0 './is_color_enabled.sh' 'color.wrong' 'color.doit' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.wrong' 'color.nowait' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.wrong' 'color.nowait' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')
"

__test_section__ 'a few missing and wrong values and then a correct value'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 'color.wrong' 'color.bar' 'color.wrong2' 'color.doit' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"
assert_exit_code__light 0 './is_color_enabled.sh' 'color.foo' 'color.wrong' 'color.bar' 'color.wrong2' 'color.doit' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 'color.wrong' 'color.bar' 'color.wrong2' 'color.nowait' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"
assert_exit_code__light 1 './is_color_enabled.sh' 'color.foo' 'color.wrong' 'color.bar' 'color.wrong2' 'color.nowait' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs_with_color '' "
	$(create_bad_boolean_config_value_regex 'tomato' 'color.wrong')\\n
	$(create_bad_boolean_config_value_regex 'potato' 'color.wrong2')
"

__test_section__ 'a correct value folowed by a wrong value'
assert_exit_code__light 0 './is_color_enabled.sh' 'color.doit' 'color.wrong' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs '' ''
assert_exit_code__light 0 './is_color_enabled.sh' 'color.doit' 'color.wrong' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs '' ''
assert_exit_code__light 1 './is_color_enabled.sh' 'color.nowait' 'color.wrong' 1>/dev/tty 2>stderr
stderr="$(cat stderr)"
assert_outputs '' ''
assert_exit_code__light 1 './is_color_enabled.sh' 'color.nowait' 'color.wrong' 1>/dev/null 2>stderr
stderr="$(cat stderr)"
assert_outputs '' ''
