. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'color_hint.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
printf 'foo\n' | color_hint
EOF
chmod +x 'color_hint.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

git config --local color.ui always

__test_section__ 'none set'
assert_exit_code 0 './color_hint.sh'
assert_outputs '\[33mfoo\[0?m' ''

__test_section__ 'only vanilla set'
git config --local color.advice.hint green
assert_exit_code 0 './color_hint.sh'
assert_outputs '\[32mfoo\[0?m' ''

__test_section__ 'both set'
git config --local color.istash.advice.hint blue
assert_exit_code 0 './color_hint.sh'
assert_outputs '\[34mfoo\[0?m' ''

__test_section__ 'only istash set'
git config --local --unset color.advice.hint
assert_exit_code 0 './color_hint.sh'
assert_outputs '\[34mfoo\[0?m' ''
