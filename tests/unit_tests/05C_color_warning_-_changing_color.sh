. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'color_warning.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
printf 'foo\n' | color_warning
EOF
chmod +x 'color_warning.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

git config set --local color.ui always

__test_section__ 'not set'
assert_exit_code 0 './color_warning.sh'
assert_outputs '\[33mfoo\[0?m' ''

__test_section__ 'set'
git config set --local color.istash.error.warning green
assert_exit_code 0 './color_warning.sh'
assert_outputs '\[32mfoo\[0?m' ''
