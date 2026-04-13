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

git config set --local 'color.thebestcolor' 'bold cyan'
git config set --local 'color.alittleworsecolor' 'green'

__test_section__ 'with no argument'
assert_exit_code 128 './get_color.sh'

__test_section__ 'with only default value'
assert_exit_code 0 './get_color.sh' 'red'
assert_outputs '\[31m' ''

__test_section__ 'with variable instead of the default value'
assert_exit_code 128 './get_color.sh' 'color/alittleworsecolor'

__test_section__ 'with default value and a variable'
assert_exit_code 0 './get_color.sh' 'red' 'color.thebestcolor'
assert_outputs '\[1;36m' ''

__test_section__ 'with default value and two variables'
assert_exit_code 0 './get_color.sh' 'red' 'color.thebestcolor' 'color.alittleworsecolor'
assert_outputs '\[1;36m' ''
