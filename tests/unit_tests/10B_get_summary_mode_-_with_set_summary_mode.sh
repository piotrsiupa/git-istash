. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'set_and_get_summary_mode.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
set_summary_mode "\$1"
get_summary_mode
EOF
chmod +x 'set_and_get_summary_mode.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

__test_section__ '<default>'
GIT_CONFIG_GLOBAL='' assert_exit_code 0 './set_and_get_summary_mode.sh' 'complete'
assert_outputs 'complete' ''
GIT_CONFIG_GLOBAL='' assert_exit_code 0 './set_and_get_summary_mode.sh' 'non-ignored'
assert_outputs 'non-ignored' ''
GIT_CONFIG_GLOBAL='' assert_exit_code 0 './set_and_get_summary_mode.sh' 'off'
assert_outputs 'off' ''

__test_section__ 'complete'
git config set --local istash.summary complete
assert_exit_code 0 './set_and_get_summary_mode.sh' 'complete'
assert_outputs 'complete' ''
assert_exit_code 0 './set_and_get_summary_mode.sh' 'non-ignored'
assert_outputs 'non-ignored' ''
assert_exit_code 0 './set_and_get_summary_mode.sh' 'off'
assert_outputs 'off' ''

__test_section__ 'non-ignored'
git config set --local istash.summary non-ignored
assert_exit_code 0 './set_and_get_summary_mode.sh' 'complete'
assert_outputs 'complete' ''
assert_exit_code 0 './set_and_get_summary_mode.sh' 'non-ignored'
assert_outputs 'non-ignored' ''
assert_exit_code 0 './set_and_get_summary_mode.sh' 'off'
assert_outputs 'off' ''

__test_section__ 'off'
git config set --local istash.summary off
assert_exit_code 0 './set_and_get_summary_mode.sh' 'complete'
assert_outputs 'complete' ''
assert_exit_code 0 './set_and_get_summary_mode.sh' 'non-ignored'
assert_outputs 'non-ignored' ''
assert_exit_code 0 './set_and_get_summary_mode.sh' 'off'
assert_outputs 'off' ''
