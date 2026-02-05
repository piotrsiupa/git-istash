. "$(dirname "$0")/../commons.sh" 1>/dev/null

__end_of_initialization__

prepare_repository

# A wrapper because shell anticks will screw up error handling if it's sourced directly.
cat >'color_lines.sh' <<EOF
#!/usr/bin/env sh
. '$(cd - 1>/dev/null ; pwd)/../lib/git-istash/git-istash-commons'
printf '#'
color_lines "\$@"
printf '#'
EOF
chmod +x 'color_lines.sh'

empty_text_file='empty-text.txt'
short_text_no_eol_file='short-text.txt'
short_text_file='short-text-eol.txt'
long_text_no_eol_file='long-text.txt'
long_text_file='long-text-eol.txt'
printf '' >"$empty_text_file"
printf 'Whoever reads this - you are great!' >"$short_text_no_eol_file"
{ cat "$short_text_no_eol_file" ; printf '\n' ; } >"$short_text_file"
printf '%s' 'Lorem ipsum dolor sit amet, consectetur adipiscing elit,
sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.' >"$long_text_no_eol_file"
{ cat "$long_text_no_eol_file" ; printf '\n' ; } >"$long_text_file"

__test_section__ 'empty stream'
assert_exit_code 0 './color_lines.sh' 'magenta' <"$empty_text_file"
assert_outputs '##' ''

__test_section__ 'single line stream without eol'
assert_exit_code 0 './color_lines.sh' 'magenta' <"$short_text_no_eol_file"
assert_outputs '#\[35mWhoever reads this - you are great!\[0?m#' ''

__test_section__ 'single line stream with eol'
assert_exit_code 0 './color_lines.sh' 'magenta' <"$short_text_file"
assert_outputs '#\[35mWhoever reads this - you are great!\[0?m\n#' ''

__test_section__ 'multiline line stream without eol at eof'
assert_exit_code 0 './color_lines.sh' 'magenta' <"$long_text_no_eol_file"
assert_outputs '#
	\[35mLorem ipsum dolor sit amet, consectetur adipiscing elit,\[0?m\n
	\[35msed do eiusmod tempor incididunt ut labore et dolore magna aliqua\.\[0?m\n
	\[35mUt enim ad minim veniam,\[0?m\n
	\[35mquis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat\.\[0?m
	#' ''

__test_section__ 'multiline line stream with eol at eof'
assert_exit_code 0 './color_lines.sh' 'magenta' <"$long_text_file"
assert_outputs '#
	\[35mLorem ipsum dolor sit amet, consectetur adipiscing elit,\[0?m\n
	\[35msed do eiusmod tempor incididunt ut labore et dolore magna aliqua\.\[0?m\n
	\[35mUt enim ad minim veniam,\[0?m\n
	\[35mquis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat\.\[0?m\n
	#' ''
