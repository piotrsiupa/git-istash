. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'get_summary_mode.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
get_summary_mode
EOF
chmod +x 'get_summary_mode.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

__test_section__ 'carrot'
git config --local istash.summary carrot
assert_exit_code 1 './get_summary_mode.sh'
assert_outputs__apply__invalid_summary_mode 'carrot'

__test_section__ 'only-ignored'
git config --local istash.summary only-ignored
assert_exit_code 1 './get_summary_mode.sh'
assert_outputs__apply__invalid_summary_mode 'only-ignored'

__test_section__ 'auto'
git config --local istash.summary auto
assert_exit_code 1 './get_summary_mode.sh'
assert_outputs__apply__invalid_summary_mode 'auto'

__test_section__ '?@$#.'
git config --local istash.summary '?@$#.'
assert_exit_code 1 './get_summary_mode.sh'
assert_outputs__apply__invalid_summary_mode '?@$#.'
