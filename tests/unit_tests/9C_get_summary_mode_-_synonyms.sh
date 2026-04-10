# Those aren't really docummanted but yes, they are guaranteed.
# The goal is to let user write anything sensible and have it still working.
# (It's not a comprehensive list of everything that works.)

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

__test_section__ 'FULL'
git config --local istash.summary FULL
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'complete' ''

__test_section__ 'on'
git config --local istash.summary on
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'complete' ''

__test_section__ 'yes'
git config --local istash.summary yes
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'complete' ''

__test_section__ 'y'
git config --local istash.summary y
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'complete' ''

__test_section__ 'true'
git config --local istash.summary true
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'complete' ''

__test_section__ 't'
git config --local istash.summary t
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'complete' ''

__test_section__ 'always'
git config --local istash.summary always
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'complete' ''

__test_section__ 'non-ign'
git config --local istash.summary non-ign
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'non-ignored' ''

__test_section__ 'N-I'
git config --local istash.summary N-I
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'non-ignored' ''

__test_section__ 'only-non-ignored'
git config --local istash.summary only-non-ignored
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'non-ignored' ''

__test_section__ 'non-ign-only'
git config --local istash.summary non-ign-only
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'non-ignored' ''

__test_section__ 'without-ignored'
git config --local istash.summary without-ignored
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'non-ignored' ''

__test_section__ 'OFF'
git config --local istash.summary OFF
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'off' ''

__test_section__ 'no'
git config --local istash.summary no
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'off' ''

__test_section__ 'false'
git config --local istash.summary false
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'off' ''

__test_section__ 'f'
git config --local istash.summary f
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'off' ''

__test_section__ 'never'
git config --local istash.summary never
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'off' ''

__test_section__ 'N'
git config --local istash.summary N
assert_exit_code 0 './get_summary_mode.sh'
assert_outputs 'off' ''
