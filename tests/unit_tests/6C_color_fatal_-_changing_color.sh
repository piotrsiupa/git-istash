. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'color_fatal.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-commons'
printf 'foo\n' | color_fatal
EOF
chmod +x 'color_fatal.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

git config --local color.ui always

__test_section__ 'none set'
assert_exit_code 0 './color_fatal.sh'
assert_outputs '\[1;31mfoo\[0?m'

__test_section__ 'only default set'
git config --local color.istash.error.default green
assert_exit_code 0 './color_fatal.sh'
assert_outputs '\[32mfoo\[0?m'

__test_section__ 'both set'
git config --local color.istash.error.fatal blue
assert_exit_code 0 './color_fatal.sh'
assert_outputs '\[34mfoo\[0?m'

__test_section__ 'default set'
git config --local --unset color.istash.error.default
assert_exit_code 0 './color_fatal.sh'
assert_outputs '\[34mfoo\[0?m'
