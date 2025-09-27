# These are only a few rudimentary checks for things that are the easiest to forgot / mess up.
# Always validate you're documentation manually.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_SUBCOMMAND

__test_section__ "Show short help for subcommand \"$SUBCOMMAND\""
#shellcheck disable=SC2086
assert_exit_code 0 git istash $SUBCOMMAND -h
mentions_of_this_subcommand="$(printf '%s\n' "$stdout" | grep -Fc "git istash $SUBCOMMAND")"
mentions_of_any_subcommand="$(printf '%s\n' "$stdout" | grep -Ec 'git istash \w+' || true)"
test "$mentions_of_this_subcommand" -ge 1 ||
	fail 'The "-h" help is not for the subcommand "%s"!\n' "$SUBCOMMAND"
test "$mentions_of_this_subcommand" -ge "$mentions_of_any_subcommand" ||
	fail 'Other subcommands are mentioned in the "-h" help. (Did you copy it form other file?)\n'  # Not a real bug but currently the condition is fulfilled for all commands and this check will help to catch developer errors.
usage_line_regex="^Usage: git istash $SUBCOMMAND"
printf '%s\n' "$stdout" | grep -Eq "$usage_line_regex" ||
	fail 'The "-h" help doesn'\''t have a "usage" line!\n'
printf '%s\n' "$stdout" | tail -n +3 | grep -Eq "$usage_line_regex" ||
	fail 'The "-h" help starts with the "usage" line!\n(There should be a short description.)\n'
printf '%s\n' "$stdout" | grep -Fxq 'Options:' ||
	fail 'The "-h" help doesn'\''t have an "options" section!\n'
