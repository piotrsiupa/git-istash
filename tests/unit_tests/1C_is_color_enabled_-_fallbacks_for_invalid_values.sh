. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

cd - 1>/dev/null
. ../lib/git-istash/git-istash-commons
cd - 1>/dev/null

git config --local 'color.wrong' 'tomato'

__test_section__ 'no arguments'
assert_exit_code__light 128 is_color_enabled

__test_section__ 'single argument with a wrong value'
assert_exit_code__light 128 is_color_enabled 'color.wrong'

__test_section__ 'one non-existing argument and one with a wrong value'
assert_exit_code__light 128 is_color_enabled 'color.foo' 'color.wrong'

__test_section__ 'two non-existing arguments and one with a wrong value'
assert_exit_code__light 128 is_color_enabled 'color.foo' 'color.bar' 'color.wrong'
