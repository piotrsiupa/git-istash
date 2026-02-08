. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'set_color_for_all_and_check.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-commons'
set_color_for_all "\$1"
EOF
chmod +x 'set_color_for_all_and_check.sh'


__test_section__ 'blue'
assert_exit_code 1 './set_color_for_all_and_check.sh' 'blue'
assert_outputs__main_script__invalid_color_boolean 'blue'

__test_section__ 'BLUE'
assert_exit_code 1 './set_color_for_all_and_check.sh' 'BLUE'
assert_outputs__main_script__invalid_color_boolean 'BLUE'

__test_section__ 'color.ui'
assert_exit_code 1 './set_color_for_all_and_check.sh' 'color.ui'
assert_outputs__main_script__invalid_color_boolean 'color.ui'

__test_section__ 'always\nalways'
assert_exit_code 1 './set_color_for_all_and_check.sh' 'always
always'
assert_outputs '' 'error: `always\nalways'\'' is not a valid color boolean'

__test_section__ 'never\nnever'
assert_exit_code 1 './set_color_for_all_and_check.sh' 'never
never'
assert_outputs '' 'error: `never\nnever'\'' is not a valid color boolean'
