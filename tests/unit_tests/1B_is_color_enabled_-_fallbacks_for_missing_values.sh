. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE 'FALLBACK' 'miscellaneous' 'never' 'always'
test "$FALLBACK" = 'never' && FEC=1 || FEC=0

__end_of_initialization__

prepare_repository

cd - 1>/dev/null
. ../lib/git-istash/git-istash-commons
cd - 1>/dev/null

git config --local 'color.ui' "$FALLBACK"
git config --local 'color.foo' 'always'
git config --local 'color.bar' 'never'
git config --local 'color.baz' 'always'


__test_section__ 'no arguments'
assert_exit_code__light 128 is_color_enabled


__test_section__ 'single argument with existing value (always)'
assert_exit_code__light 0 is_color_enabled 'color.foo'

__test_section__ 'single argument with existing value (never)'
assert_exit_code__light 1 is_color_enabled 'color.bar'

__test_section__ 'single argument with non-existing value'
assert_exit_code__light "$FEC" is_color_enabled 'color.qwerty'


__test_section__ 'single argument with two existing values'
assert_exit_code__light 0 is_color_enabled 'color.foo' 'color.bar'

__test_section__ 'single argument with two values, first not existing'
assert_exit_code__light 1 is_color_enabled 'color.qwerty' 'color.bar'

__test_section__ 'single argument with two values, second not existing'
assert_exit_code__light 0 is_color_enabled 'color.foo' 'color.asdfgh'

__test_section__ 'single argument with two non-existing values'
assert_exit_code__light "$FEC" is_color_enabled 'color.qwerty' 'color.asdfgh'


__test_section__ 'single argument with two values, variant 0'
assert_exit_code__light 0 is_color_enabled 'color.foo' 'color.bar' 'color.baz'

__test_section__ 'single argument with two values, variant 1'
assert_exit_code__light 1 is_color_enabled 'color.qwerty' 'color.bar' 'color.baz'

__test_section__ 'single argument with two values, variant 2'
assert_exit_code__light 0 is_color_enabled 'color.foo' 'color.asdfgh' 'color.baz'

__test_section__ 'single argument with two values, variant 3'
assert_exit_code__light 0 is_color_enabled 'color.qwerty' 'color.asdfgh' 'color.baz'

__test_section__ 'single argument with two values, variant 4'
assert_exit_code__light 0 is_color_enabled 'color.foo' 'color.bar' 'color.zxcvbn'

__test_section__ 'single argument with two values, variant 5'
assert_exit_code__light 1 is_color_enabled 'color.qwerty' 'color.bar' 'color.zxcvbn'

__test_section__ 'single argument with two values, variant 6'
assert_exit_code__light 0 is_color_enabled 'color.foo' 'color.asdfgh' 'color.zxcvbn'

__test_section__ 'single argument with two values, variant 7'
assert_exit_code__light "$FEC" is_color_enabled 'color.qwerty' 'color.asdfgh' 'color.zxcvbn'
