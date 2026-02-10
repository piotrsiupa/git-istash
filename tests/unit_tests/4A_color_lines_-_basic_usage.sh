. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'color_lines.sh' <<EOF
#!/usr/bin/env sh
set -eu
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-commons'
color_lines "\$@"
EOF
chmod +x 'color_lines.sh'
ln -s "$(cd - 1>/dev/null ; pwd)/../lib/git-istash/get_options" ./

git config --local 'color.thebestcolor' 'bold cyan'
git config --local 'color.alittleworsecolor' 'green'
git config --local 'color.incorrectcolor' 'color'

short_text_file='short-text.txt'
printf 'Whoever reads this - you are great!\n' >"$short_text_file"

# Those tests cover things that are mostly that are the some in "get_colors" which "color_lines" is a wrapper for.

__test_section__ 'with no argument'
assert_exit_code 128 './color_lines.sh' <"$short_text_file"

__test_section__ 'with only default value'
assert_exit_code 0 './color_lines.sh' 'yellow' <"$short_text_file"
assert_outputs '\[33mWhoever reads this - you are great!\[0?m' ''

__test_section__ 'with variable instead of the default value'
assert_exit_code 128 './color_lines.sh' 'color/alittleworsecolor' <"$short_text_file"

__test_section__ 'with default value and a variable'
assert_exit_code 0 './color_lines.sh' 'red' 'color.thebestcolor' <"$short_text_file"
assert_outputs '\[1;36mWhoever reads this - you are great!\[0?m' ''

__test_section__ 'with default value and two variables'
assert_exit_code 0 './color_lines.sh' 'red' 'color.thebestcolor' 'color.alittleworsecolor' <"$short_text_file"
assert_outputs '\[1;36mWhoever reads this - you are great!\[0?m' ''

__test_section__ 'with default value and two variables, first non-existing'
assert_exit_code 0 './color_lines.sh' 'red' 'color.nonexistingcolor' 'color.alittleworsecolor' <"$short_text_file"
assert_outputs '\[32mWhoever reads this - you are great!\[0?m' ''

__test_section__ 'with default value and two variables, first incorrect'
assert_exit_code 128 './color_lines.sh' 'red' 'color.incorrectcolor' 'color.alittleworsecolor' <"$short_text_file"
