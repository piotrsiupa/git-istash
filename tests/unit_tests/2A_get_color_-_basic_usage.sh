. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

cd - 1>/dev/null
. ../lib/git-istash/git-istash-commons
cd - 1>/dev/null

# Parsing colors won't be extensively tested because it's done by a Git function.
# This focuses on the fallback system and corner cases.

git config --local 'color.thebestcolor' 'bold cyan'
git config --local 'color.alittleworsecolor' 'green'

__test_section__ 'with no argument'
assert_exit_code 128 get_color

__test_section__ 'with only default value'
assert_exit_code 0 get_color 'red'
assert_outputs '\[31m' ''

__test_section__ 'with variable instead of the default value'
assert_exit_code 128 get_color 'color/alittleworsecolor'

__test_section__ 'with default value and a variable'
assert_exit_code 0 get_color 'red' 'color.thebestcolor'
assert_outputs '\[1;36m' ''

__test_section__ 'with default value and two variables'
assert_exit_code 0 get_color 'red' 'color.thebestcolor' 'color.alittleworsecolor'
assert_outputs '\[1;36m' ''
