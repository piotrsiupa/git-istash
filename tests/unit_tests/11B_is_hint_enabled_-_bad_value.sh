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
is_quiet=n
export is_quiet
chmod +x 'is_hint_enabled.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

__test_section__ '"asdf"'
git config set --local advice.istashTest asdf
assert_exit_code 0 './is_hint_enabled.sh' 'Test'
assert_outputs_with_color '' "$(create_bad_boolean_config_value_regex 'asdf' 'advice.istashTest')"

__test_section__ '"auto"'
git config set --local advice.istashTest auto
assert_exit_code 0 './is_hint_enabled.sh' 'Test'
assert_outputs_with_color '' "$(create_bad_boolean_config_value_regex 'auto' 'advice.istashTest')"
