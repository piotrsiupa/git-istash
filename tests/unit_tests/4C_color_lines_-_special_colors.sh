. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'color_lines.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-io'
color_lines "\$@"
EOF
chmod +x 'color_lines.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

short_text_file='short-text.txt'
printf 'Whoever reads this - you are great!\n' >"$short_text_file"

# Those tests cover things that are mostly that are the some in "get_colors" which "color_lines" is a wrapper for.

__test_section__ 'with color "normal"'
assert_exit_code 0 './color_lines.sh' 'normal' <"$short_text_file"
assert_outputs 'Whoever reads this - you are great!' ''

__test_section__ 'with color "default"'
assert_exit_code 0 './color_lines.sh' 'default' <"$short_text_file"
assert_outputs '\[39mWhoever reads this - you are great!\[0?m' ''
