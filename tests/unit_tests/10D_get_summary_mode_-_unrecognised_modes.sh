. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'get_summary_mode.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
is_quiet=n
get_summary_mode
EOF
chmod +x 'get_summary_mode.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

__test_section__ 'carrot'
git config set --local istash.summary carrot
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs_with_color 'complete' "$(create_bad_summary_mode_regex 'carrot')"

__test_section__ 'only-ignored'
git config set --local istash.summary only-ignored
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs_with_color 'complete' "$(create_bad_summary_mode_regex 'only-ignored')"

__test_section__ 'auto'
git config set --local istash.summary auto
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs_with_color 'complete' "$(create_bad_summary_mode_regex 'auto')"

__test_section__ '?@$#.'
git config set --local istash.summary '?@$#.'
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs_with_color 'complete' "$(create_bad_summary_mode_regex '?@$#.')"
