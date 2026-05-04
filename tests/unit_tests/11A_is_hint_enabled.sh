. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'is_hint_enabled.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
is_hint_enabled "\$1"
EOF
chmod +x 'is_hint_enabled.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

__test_section__ '<no value>'
assert_exit_code 0 './is_hint_enabled.sh' 'Aaa'
assert_outputs '' ''
assert_exit_code 0 './is_hint_enabled.sh' 'Bbb'
assert_outputs '' ''
assert_exit_code 0 './is_hint_enabled.sh' 'Ccc'
assert_outputs '' ''

__test_section__ 'false-ish values'
git config set --local advice.istashAaa false
git config set --local advice.istashBbb 0
git config set --local advice.istashCcc off
assert_exit_code 1 './is_hint_enabled.sh' 'Aaa'
assert_outputs '' ''
assert_exit_code 1 './is_hint_enabled.sh' 'Bbb'
assert_outputs '' ''
assert_exit_code 1 './is_hint_enabled.sh' 'Ccc'
assert_outputs '' ''

__test_section__ 'true-ish values'
git config set --local advice.istashAaa true
git config set --local advice.istashBbb 1
git config set --local advice.istashCcc on
assert_exit_code 0 './is_hint_enabled.sh' 'Aaa'
assert_outputs '' ''
assert_exit_code 0 './is_hint_enabled.sh' 'Bbb'
assert_outputs '' ''
assert_exit_code 0 './is_hint_enabled.sh' 'Ccc'
assert_outputs '' ''

__test_section__ 'true-ish values'
GIT_ADVICE=0
export GIT_ADVICE
assert_exit_code 1 './is_hint_enabled.sh' 'Aaa'
assert_outputs '' ''
assert_exit_code 1 './is_hint_enabled.sh' 'Bbb'
assert_outputs '' ''
assert_exit_code 1 './is_hint_enabled.sh' 'Ccc'
assert_outputs '' ''
