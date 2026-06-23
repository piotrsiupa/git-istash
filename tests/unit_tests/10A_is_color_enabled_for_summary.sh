. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'is_color_enabled_for_summary.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
is_color_enabled_for_summary
EOF
chmod +x 'is_color_enabled_for_summary.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

__test_section__ 'never'
git config --local color.ui never
assert_exit_code 1 './is_color_enabled_for_summary.sh'
assert_outputs '' ''

__test_section__ 'never <- always'
git config --local color.status always
assert_exit_code 0 './is_color_enabled_for_summary.sh'
assert_outputs '' ''

__test_section__ 'never <- never'
git config --local color.status never
assert_exit_code 1 './is_color_enabled_for_summary.sh'
assert_outputs '' ''

__test_section__ 'never <- never <- always'
git config --local color.istash always
assert_exit_code 0 './is_color_enabled_for_summary.sh'
assert_outputs '' ''

__test_section__ 'never <- never <- never'
git config --local color.istash never
assert_exit_code 1 './is_color_enabled_for_summary.sh'
assert_outputs '' ''

__test_section__ 'never <- never <- never <- always'
git config --local color.istash.summary always
assert_exit_code 0 './is_color_enabled_for_summary.sh'
assert_outputs '' ''

__test_section__ 'never <- never <- never <- never'
git config --local color.istash.summary never
assert_exit_code 1 './is_color_enabled_for_summary.sh'
assert_outputs '' ''

__test_section__ 'always <- always <- always <- never'
git config --local color.ui always
git config --local color.status always
git config --local color.istash always
assert_exit_code 1 './is_color_enabled_for_summary.sh'
assert_outputs '' ''
