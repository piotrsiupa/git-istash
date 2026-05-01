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

__test_section__ '<default>'
GIT_CONFIG_GLOBAL='' assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'complete' ''

__test_section__ 'complete'
git config set --local istash.summary complete
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'complete' ''

__test_section__ 'non-ignored'
git config set --local istash.summary non-ignored
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'non-ignored' ''

__test_section__ 'off'
git config set --local istash.summary off
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'off' ''
