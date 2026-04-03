. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'get_color_for_summary.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
get_color_for_summary "\$@"
EOF
chmod +x 'get_color_for_summary.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

git config --local color.ui always

__test_section__ 'none set'
assert_exit_code 0 './get_color_for_summary.sh' 'added'
assert_outputs '\[32m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[32m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'changed'
assert_outputs '\[31m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'untracked'
assert_outputs '\[31m' ''

__test_section__ 'only vanilla set'
git config --local color.status.added 'blue'
git config --local color.status.updated 'cyan'
git config --local color.status.changed 'yellow'
git config --local color.status.untracked 'magenta'
assert_exit_code 0 './get_color_for_summary.sh' 'added'
assert_outputs '\[34m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[36m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'changed'
assert_outputs '\[33m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'untracked'
assert_outputs '\[35m' ''

__test_section__ 'both set'
git config --local color.istash.summary.added 'bold red'
git config --local color.istash.summary.updated 'black'
git config --local color.istash.summary.changed 'bold yellow'
git config --local color.istash.summary.untracked 'green'
assert_exit_code 0 './get_color_for_summary.sh' 'added'
assert_outputs '\[1;31m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[30m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'changed'
assert_outputs '\[1;33m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'untracked'
assert_outputs '\[32m' ''

__test_section__ 'only istash set'
git config --local --unset color.status.added
git config --local --unset color.status.updated
git config --local --unset color.status.changed
git config --local --unset color.status.untracked
assert_exit_code 0 './get_color_for_summary.sh' 'added'
assert_outputs '\[1;31m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'updated'
assert_outputs '\[30m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'changed'
assert_outputs '\[1;33m' ''
assert_exit_code 0 './get_color_for_summary.sh' 'untracked'
assert_outputs '\[32m' ''
