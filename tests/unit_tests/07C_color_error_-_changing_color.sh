. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'color_error.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
printf 'foo\n' | color_error
EOF
chmod +x 'color_error.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

git config --local color.ui always

__test_section__ 'none set'
assert_exit_code 0 './color_error.sh'
assert_outputs '\[31mfoo\[0?m' ''

__test_section__ 'only default set'
git config --local color.istash.error.default green
assert_exit_code 0 './color_error.sh'
assert_outputs '\[32mfoo\[0?m' ''

__test_section__ 'both set'
git config --local color.istash.error.normal blue
assert_exit_code 0 './color_error.sh'
assert_outputs '\[34mfoo\[0?m' ''

__test_section__ 'only normal set'
git config --local --unset color.istash.error.default
assert_exit_code 0 './color_error.sh'
assert_outputs '\[34mfoo\[0?m' ''
