. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'color_error.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
set_color_for_all "\$1"
printf 'foo\n' | color_error
EOF
chmod +x 'color_error.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

__test_section__ 'always (overriden to never)'
git config --local color.ui always
assert_exit_code 0 './color_error.sh' 'never'
assert_outputs 'foo' ''

__test_section__ 'never (overriden to always)'
git config --local color.ui never
assert_exit_code 0 './color_error.sh' 'always'
assert_outputs '\[31mfoo\[0?m' ''

__test_section__ 'never <- always (overriden to never)'
git config --local color.istash always
assert_exit_code 0 './color_error.sh' 'never'
assert_outputs 'foo' ''

__test_section__ 'never <- never (overriden to always)'
git config --local color.istash never
assert_exit_code 0 './color_error.sh' 'always'
assert_outputs '\[31mfoo\[0?m' ''

__test_section__ 'never <- never <- always (overriden to never)'
git config --local color.istash.error always
assert_exit_code 0 './color_error.sh' 'never'
assert_outputs 'foo' ''

__test_section__ 'never <- never <- never (overriden to always)'
git config --local color.istash.error never
assert_exit_code 0 './color_error.sh' 'always'
assert_outputs '\[31mfoo\[0?m' ''
