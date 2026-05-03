#!/usr/bin/env sh

# This script is intended mostly to be sourced by other scripts.
# It can also run independently but unlike other script all that code is in a second section.

set -eu


normalize_facet_list() { # list
	printf '%s\n' "$1" \
	| sed -E -e 's/\s*#.*$//' \
		-e 's/\s+//g' \
		-e '/^$/d'
}


# Format: <canonical_spelling> = <other_spellings_regex>
raw_facets='
	# Run tests marked as non-essential. (Essential tests check mostly the happy path of the common cases.)
	non-essential = ne|n(on)?[-_]e(ss(en(t(ials?)?)?)?)?
	
	# Run tests for HEAD a normal branch, an orphan branch and a commit detached from a branch.
	head-type = ht|h(ead)?([-_]t(ypes?)?)?
	
	# Run tests for a few chosen combinations of pathspec from arguments / stdin / file in a plain text / null separated format.
	pathspec-style = p?ps|(p(a(r(t(ial)?)?)?)?[-_])?pa?(th)?s(p(ec)?)?[-_]s(t(y(l(es?)?)?)?)?
	
	# Run tests for all the combinations of pathspec from arguments / stdin / file in a plain text / null separated format.
	full-pathspec-style = fps|f(u?ll)?[-_]?pa?(th)?s(p(ec)?)?[-_]s(t(y(l(es?)?)?)?)?
	
	# Run tests for all the subcommands applicable for the given test. (E.g. instead of just "create" test "create", "save", "snatch" and "push".)
	subcommand = (s(u?b)?[-_]?)?(c(om(m(an(ds?)?)?)?)?|subs?|cmds?)
	
	# Test various options applicable for given test. (E.g. try to run the same test with and without "--keep-index".)
	# (See also "short-options" and "partial-options".)
	# This focuses on the options that tends to inteact with each other. See also "color", "hint" and "summary".
	options = o(p(t(i(o(ns?)?)?|s|))?)?
	
	# Test both short and long variants of the same option (and sometimes other things like config variables).
	# (E.g. "--continue" and "-c".)
	short-options = so|s(h(o?rt)?)?[-_]o(p(t(i(o(ns?)?)?|s|))?)?
	
	# Test also shortened spelling for options (and sometimes other things like config variables).
	# (E.g. "--conti" instead of "--continue".)
	partial-options = po|p(a(r(t(ial)?)?)?)?[-_]o(p(t(i(o(ns?)?)?|s|))?)?
	
	# Test both with colors tuner on and off. (They are on by default in tests.)
	# (See also "short-options" and "partial-options".)
	color = c(o(l(o(rs?)?)?)?)?
	
	# Test both enabled and disabled hints. (By default test only enabled.)
	# (See also "short-options" and "partial-options".)
	hint = h(i?nts?)?
	
	# Test full / partial / no summary after an apply operation. (By default, full summary is tested.)
	# (See also "short-options" and "partial-options".)
	summary = sum(m(a(ry?)?)?)?
	
	# Test also the command run with "--" between options and arguments.
	end-options-indicator = e?oi|(e(nd)?[-_])?o(p(t(i(o(ns?)?)?|s|))?)?[-_]i(n(d(i(c(a(t(or)?)?)?)?)?)?)?|eo|e(nd)?[-_]o(p(t(i(o(ns?)?)?|s|))?)?|ei|e(nd)?[-_]i(n(d(i(c(a(t(ors?)?)?)?)?)?)?)?
	
	# Run the tests that take a long time to execute.
	# (Only a few tests are like that but they still inhibit things noticeably.)
	long-running = lr|l(o?ng)?[-_]r(u(n(n(ing)?)?)?)?
	
	# Run also alternative versions of some tests.
	miscellaneous = m(i(s(c(ell?(a(n(e?o?u?s)?)?)?)?)?)?)?
'
facets="$(normalize_facet_list "$raw_facets")"


# Format: <canonical_spelling> = <other_spellings_regex>: [<component>,]...
raw_facet_categories='
	# Test everything, including things that need testing very rarely if ever. (very excessive)
	# (Some tests will not even finish, because there will be too many runs.)
	all = a(ll)?: '"$(printf '%s' "$facets" | sed -E 's/^(.+)=.*$/\1/' | tr '\n' ',')"'
	
	# Test everything important and a little more, just to be sure.
	full = fu?ll: standard, full-pathspec-style, color, hint, summary, long-running
	
	# Test the important things.
	# (It gives a pretty good idea of whether everything works.)
	standard = std|sta(n(d(ard)?)?)?: fast, partial-pathspec-style, short-options
	
	# Test the most important things.
	# (It is fast but not that thorough. It is usually good enough for testing mid-development.)
	fast = fa?st: non-essential, head-type, subcommand, options, miscellaneous
	
	# Only non essential tests.
	# (Checks if the shell is able run the scripts but not that much more - no tricky cases.)
	minimal = m(i(n(im(al)?)?)?)?:
'
facet_categories="$(normalize_facet_list "$raw_facet_categories")"


# It errors out if a line is neither a facet nor a facet category.
canonize_facet_names() (
	set -eu
	names="$(cat)"
	{
		printf '%s\n' "$facets" | sed -E 's/^([^=]+)=(.*)$/\1\n\2/'
		printf '%s\n' "$facet_categories" | sed -E 's/^([^=]+)=(.*):[^:]*$/\1\n\2/'
	} | {
		while read -r canon_name
		do
			read -r name_regex
			names="$(printf '%s\n' "$names" | sed -E "s/^($name_regex)\$/$canon_name/")"
		done
		verify_regex="$(
			printf '%s\n%s' "$facets" "$facet_categories" \
			| sed -E 's/^([^=]+)=.*$/\1/' \
			| tr '\n' '|'
		)"
		unknown_names="$(printf '%s\n' "$names" | grep -E -x -v "$verify_regex" || true)"
		if [ -z "$unknown_names" ]
		then
			printf '%s\n' "$names"
		else
			printf 'The following facet names are not recognized:\n' 1>&2
			printf '%s\n' "$unknown_names" | sed -E 's/^/ - /' 1>&2
			return 1
		fi
	}
)

# It works kinda like "sort -u" except it sorts in the order as they are in the "facets".
# It assumes that every input line is an existing facet.
sort_u_facets() (
	set -eu
	facet_regex="^($(tr '\n' '|'))\$"
	printf '%s\n' "$facets" \
	| sed -E 's/^([^=]+)=.*$/\1/' \
	| grep -E "$facet_regex" || true
)

# It takes lists of facets and facet lists. It breaks the lists into individual facets, deduplicates and sorts the list.
parse_meticulousness() ( # [facet_list]...
	set -eu
	names="$(
		printf '%s\n' "$@" \
		| tr ',' '\n' \
		| sed -E '/^$/d' \
		| canonize_facet_names
	)"
	while true
	do
		categories_pattern="^($(printf '%s' "$names" | tr '\n' '|'))="
		matched_categories="$(printf '%s' "$facet_categories" | grep -E "$categories_pattern" || true)"
		if [ -z "$matched_categories" ]
		then
			break
		fi
		matched_categories_name_regex="^($(printf '%s' "$matched_categories" | sed -E 's/^([^=]+)=.*$/\1/' | tr '\n' '|'))\$"
		names="$(
			printf '%s\n' "$names" | grep -E -v "$matched_categories_name_regex" || true
			printf '%s\n' "$matched_categories" | sed -E 's/^.*:([^:]*)$/\1/' | tr ',' '\n'
		)"
	done
	printf '%s' "$names" | sort_u_facets
)


# ------------------------------------------------------------------------------


# Do this only if the script doesn't appear to be sourced.
if [ $# -ne 0 ] && [ "$(basename "$0" 2>/dev/null)" = 'facets.sh' ]
then
	break_long_lines() { # new_line_prefix
		while IFS= read -r line
		do
			while true
			do
				line_length="$(printf '%s' "$line" | wc -L)"
				if [ "$line_length" -le 80 ]
				then
					break
				fi
				cut_line="$(
					printf '%s\n' "$line" \
					| head -c$((${#line} - (line_length - 80) + 1)) \
					| sed -E 's/ [^ ]*$//'
				)"
				printf '%s\n' "$cut_line"
				#shellcheck disable=SC2059
				line="$(printf "$1")$(printf '%s' "$line" | tail -c+$((${#cut_line} + 2)))"
			done
			printf '%s\n' "$line"
		done
	}
	
	pretty_print() { # list_of_facets_or_facet_categories
		printf '%s' "$1" \
		| sed -E -e 's/^\s+//' -e 's/^([^= ]+) *=[^:]*(:[^:]*)?$/\1\2/' \
		| tr '\n' '~' \
		| sed -E -e 's/~~|~$/\n/g' -e 's/^~//' \
		| while read -r entry
		do
			printf ' - '
			name="$(printf '%s' "$entry" | sed -E 's/^.*~([^~:]+)(:[^~:]*)?$/\1/')"
			printf '%s' "$name"
			if [ ${#name} -lt $((8-3)) ]
			then
				printf '\t'
			fi
			if [ ${#name} -lt $((16-3)) ]
			then
				printf '\t'
			else
				printf ' '
			fi
			printf -- '- '
			printf '%s' "$entry" \
			| sed -E -e 's/~[^~]+$//' \
				-e 's/(^|~)\s*#\s*/\1/g' \
				-e 's/~/\n\t\t  /g'
			printf '\n'
			if printf '%s\n' "$entry" | grep -E -q ':'
			then
				printf '\t\t  Includes: '
				if printf '%s\n' "$entry" | grep -E -q ':$'
				then
					printf '<nothing>'
				else
					printf '%s' "$entry" \
					| sed -E 's/^.*://' \
					| tr -d ' ' \
					| sed -E -e 's/,/, /g' -e 's/,([^,]+)$/ and\1/'
				fi
				printf '.\n'
			fi
		done \
		| break_long_lines '\t\t  '
	}
	
	print_help() {
		printf 'This is a simple script that just parses meticulousness into facets.\n'
		printf 'Meticulousness is just a name for a list of facets / facet categories.)\n'
		printf 'It reads arguments or stdin if the first argument is "-".\n'
		printf '\n'
		printf 'Usage: %s (-h | --help | --version)\n' "$(basename "$0")"
		printf '   or: %s [<meticulousness>...]\n' "$(basename "$0")"
		printf '   or: %s -\n' "$(basename "$0")"
		printf '\n'
		printf 'Options:\n'
		printf '    -h, --help\t\t- Print this help text.\n'
		printf '    -v, --version\t- Print version information and exit.\n'
		printf '\n'
		printf 'Facets:\n'
		pretty_print "$raw_facets"
		printf '\n'
		printf 'Facet categories:\n'
		pretty_print "$raw_facet_categories"
		printf '\n'
		printf '(Some of the names are rather long to type, but regexes used to parse the input\nare very lenient when it comes to abbreviating. '
		printf 'As long as the abbreviation is\nunique to one name, the script should allow it.)\n'
		printf '\n'
		printf 'See also "run.sh --help" to read about testing multiple lists of facets at once\nincluding some predefined ones that may be more useful than the categories here.\n'
	}
	
	print_version() {
		printf 'test facets parsing script version 1.0.0\n'
	}
	
	getopt_short_options='hv'
	getopt_long_options='help,version'
	normalized_options="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
	eval set -- "$normalized_options"
	while true
	do
		case "$1" in
		-h|--help)
			print_help
			exit 0
			;;
		-v|--version)
			print_version
			exit 0
			;;
		--)
			shift
			break
			;;
		esac
		shift
	done
	
	if [ "$1" = '-' ]
	then
		parse_meticulousness "$(cat)"
	else
		parse_meticulousness "$@"
	fi
fi
