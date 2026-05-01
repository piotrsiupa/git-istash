. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository
unset GIT_CONFIG_COUNT

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'get_color_for_summary.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
get_color_for_summary "\$@"
EOF
chmod +x 'get_color_for_summary.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

git config set --local color.ui always

__test_section__ 'none set'
assert_exit_code 0 './get_color_for_summary.sh' 'header'
assert_outputs '' ''
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[32m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'changed'
assert_outputs '\[31m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'untracked'
assert_outputs '\[31m' ''

__test_section__ 'only vanilla set'
git config set --local color.status.header 'default'
git config set --local color.status.added 'blue'
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[34m' ''
git config set --local color.status.updated 'cyan'
git config set --local color.status.changed 'yellow'
git config set --local color.status.untracked 'magenta'
assert_exit_code 0 './get_color_for_summary.sh' 'header'
assert_outputs '\[39m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[36m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'changed'
assert_outputs '\[33m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'untracked'
assert_outputs '\[35m' ''

__test_section__ 'both set'
git config set --local color.istash.summary.header 'bold green'
git config set --local color.istash.summary.added 'bold red'
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[1;31m' ''
git config set --local color.istash.summary.updated 'black'
git config set --local color.istash.summary.changed 'bold yellow'
git config set --local color.istash.summary.untracked 'green'
assert_exit_code 0 './get_color_for_summary.sh' 'header'
assert_outputs '\[1;32m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[30m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'changed'
assert_outputs '\[1;33m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'untracked'
assert_outputs '\[32m' ''

__test_section__ 'only istash set'
git config unset --local color.status.header
git config unset --local color.status.added
git config unset --local color.status.updated
git config unset --local color.status.changed
git config unset --local color.status.untracked
assert_exit_code 0 './get_color_for_summary.sh' 'header'
assert_outputs '\[1;32m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[30m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'changed'
assert_outputs '\[1;33m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'untracked'
assert_outputs '\[32m' ''
