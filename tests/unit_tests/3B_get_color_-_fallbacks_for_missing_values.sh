. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'get_color.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-commons'
get_color "\$@"
EOF
chmod +x 'get_color.sh'

# Parsing colors won't be extensively tested because it's done by a Git function.
# This focuses on the fallback system and corner cases.

git config --local 'color.thebestcolor' 'bold cyan'
git config --local 'color.alittleworsecolor' 'green'
git config --local 'color.somethirdcolor' 'blue'


__test_section__ 'with default value and an existing variable'
assert_exit_code 0 './get_color.sh' 'red' 'color.thebestcolor'
assert_outputs '\[1;36m' ''

__test_section__ 'with default value and a non-existing variable'
assert_exit_code 0 './get_color.sh' 'red' 'color.foo'
assert_outputs '\[31m' ''


__test_section__ 'with default value and two existing variables'
assert_exit_code 0 './get_color.sh' 'red' 'color.thebestcolor' 'color.alittleworsecolor'
assert_outputs '\[1;36m' ''

__test_section__ 'with default value and good variables, first non-existing'
assert_exit_code 0 './get_color.sh' 'red' 'color.foo' 'color.alittleworsecolor'
assert_outputs '\[32m' ''

__test_section__ 'with default value and two variables, second non-existing'
assert_exit_code 0 './get_color.sh' 'red' 'color.thebestcolor' 'color.bar'
assert_outputs '\[1;36m' ''

__test_section__ 'with default value and two non-existing variables'
assert_exit_code 0 './get_color.sh' 'red' 'color.foo' 'color.bar'
assert_outputs '\[31m' ''


__test_section__ 'with default value and three existing variables, variant 0'
assert_exit_code 0 './get_color.sh' 'red' 'color.thebestcolor' 'color.alittleworsecolor' 'color.somethirdcolor'
assert_outputs '\[1;36m' ''

__test_section__ 'with default value and three existing variables, variant 1'
assert_exit_code 0 './get_color.sh' 'red' 'color.foo' 'color.alittleworsecolor' 'color.somethirdcolor'
assert_outputs '\[32m' ''

__test_section__ 'with default value and three existing variables, variant 2'
assert_exit_code 0 './get_color.sh' 'red' 'color.thebestcolor' 'color.bar' 'color.somethirdcolor'
assert_outputs '\[1;36m' ''

__test_section__ 'with default value and three existing variables, variant 3'
assert_exit_code 0 './get_color.sh' 'red' 'color.foo' 'color.bar' 'color.somethirdcolor'
assert_outputs '\[34m' ''

__test_section__ 'with default value and three existing variables, variant 4'
assert_exit_code 0 './get_color.sh' 'red' 'color.thebestcolor' 'color.alittleworsecolor' 'color.baz'
assert_outputs '\[1;36m' ''

__test_section__ 'with default value and three existing variables, variant 5'
assert_exit_code 0 './get_color.sh' 'red' 'color.foo' 'color.alittleworsecolor' 'color.baz'
assert_outputs '\[32m' ''

__test_section__ 'with default value and three existing variables, variant 6'
assert_exit_code 0 './get_color.sh' 'red' 'color.thebestcolor' 'color.bar' 'color.baz'
assert_outputs '\[1;36m' ''

__test_section__ 'with default value and three existing variables, variant 7'
assert_exit_code 0 './get_color.sh' 'red' 'color.foo' 'color.bar' 'color.baz'
assert_outputs '\[31m' ''
