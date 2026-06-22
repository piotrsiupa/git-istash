. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_GET_OPTIONS_MODE
PARAMETRIZE_GET_OPTIONS_CALL_STYLE
PARAMETRIZE_GET_OPTIONS_REMOVE_WHITESPACE

__end_of_initialization__

__test_section__ 'Without arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	"" \
	" --" \
	" --" \
	" --" \
	

__test_section__ 'Without only --'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" '--'" \
	" --" \
	" --" \
	" -- '--'" \
	--

__test_section__ 'With an argument'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" 'anger'" \
	" -- 'anger'" \
	" -- 'anger'" \
	" -- 'anger'" \
	anger

__test_section__ 'With an option'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --anger" \
	" --anger --" \
	" --anger --" \
	" --anger --" \
	--anger

__test_section__ 'With an option with a parameter'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --bloodlust ' xyz '" \
	" --bloodlust ' xyz ' --" \
	" --bloodlust ' xyz ' --" \
	" --bloodlust ' xyz ' --" \
	--bloodlust ' xyz '

__test_section__ 'With an option with an empty parameter'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --bloodlust ''" \
	" --bloodlust '' --" \
	" --bloodlust '' --" \
	" --bloodlust '' --" \
	--bloodlust ''

__test_section__ 'With an option with a parameter separated by "="'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --bloodlust ' xyz '" \
	" --bloodlust ' xyz ' --" \
	" --bloodlust ' xyz ' --" \
	" --bloodlust ' xyz ' --" \
	--bloodlust=' xyz '

__test_section__ 'With an option with an empty parameter separated by "="'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --bloodlust ''" \
	" --bloodlust '' --" \
	" --bloodlust '' --" \
	" --bloodlust '' --" \
	--bloodlust=

__test_section__ 'With an option with an optional parameter'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --evilness '' ' xyz '" \
	" --evilness '' -- ' xyz '" \
	" --evilness '' -- ' xyz '" \
	" --evilness '' -- ' xyz '" \
	--evilness ' xyz '

__test_section__ 'With an option with an optional parameter separated by "="'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --evilness ' xyz '" \
	" --evilness ' xyz ' --" \
	" --evilness ' xyz ' --" \
	" --evilness ' xyz ' --" \
	--evilness=' xyz '

__test_section__ 'With an option with an optional empty parameter separated by "="'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --evilness ''" \
	" --evilness '' --" \
	" --evilness '' --" \
	" --evilness '' --" \
	--evilness=

__test_section__ 'With a few options'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity 'a'" \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity 'a' --" \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity 'a' --" \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity 'a' --" \
	--bloodlust ' xyz ' --evilness --cruelty --fury=xyz --depravity=a

__test_section__ 'With a few repeated options'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity '--anger' --evilness 'asdfgh' --bloodlust 'qwerty' --anger --fury '' --cruelty" \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity '--anger' --evilness 'asdfgh' --bloodlust 'qwerty' --anger --fury '' --cruelty --" \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity '--anger' --evilness 'asdfgh' --bloodlust 'qwerty' --anger --fury '' --cruelty --" \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity '--anger' --evilness 'asdfgh' --bloodlust 'qwerty' --anger --fury '' --cruelty --" \
	--bloodlust ' xyz ' --evilness --cruelty --fury=xyz --depravity --anger --evilness=asdfgh --bloodlust qwerty --anger --fury --cruelty

__test_section__ 'With a few abbreviated options'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity 'a'" \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity 'a' --" \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity 'a' --" \
	" --bloodlust ' xyz ' --evilness '' --cruelty --fury 'xyz' --depravity 'a' --" \
	--blood ' xyz ' --evil --cruelt --fu=xyz --d=a

__test_section__ 'With a few abbreviation that is a name of a different option'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,blood,depravity:,evilness::,evil,fury::' \
	" --bloodlust ' xyz ' --evil --cruelty --blood --fury 'xyz' --depravity 'a'" \
	" --bloodlust ' xyz ' --evil --cruelty --blood --fury 'xyz' --depravity 'a' --" \
	" --bloodlust ' xyz ' --evil --cruelty --blood --fury 'xyz' --depravity 'a' --" \
	" --bloodlust ' xyz ' --evil --cruelty --blood --fury 'xyz' --depravity 'a' --" \
	--bloodl ' xyz ' --evil --cruelt --blood --fury=xyz --d=a

__test_section__ 'With some options and arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --cruelty --bloodlust 'a' --evilness '' 'abcd' --fury 'xyz' --depravity 'a' 'a b'\\\\''c d' --anger" \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --evilness '' -- 'abcd' '--f=xyz' '--deprav' 'a' 'a b'\\\\''c d' '--anger'" \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	--cruelty --bl=a --ev abcd --f=xyz --deprav a 'a b'\''c d' --anger

__test_section__ 'With some options and arguments and "--" before arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger '--' 'abcd' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- '--' 'abcd' 'a b'\\\\''c d'" \
	--cruelty --bloodlust=a --evilness --fury=xyz --depravity a --ang -- abcd 'a b'\''c d'

__test_section__ 'With some options and arguments and "--" in middle of arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --cruelty --bloodlust 'a' --evilness '' 'abcd' --fury 'xyz' --depravity 'a' --anger '--' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --evilness '' -- 'abcd' '--fury=xyz' '--depr' 'a' '--anger' '--' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' '--' 'a b'\\\\''c d'" \
	--cruelty --bloodlust=a --evilness abcd --fury=xyz --depr a --anger -- 'a b'\''c d'

__test_section__ 'With some options and arguments and "--" after arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --cruelty --bloodlust 'a' --evilness '' 'abcd' --fury 'xyz' --depravity 'a' 'a b'\\\\''c d' --anger '--'" \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --evilness '' -- 'abcd' '--fury=xyz' '--depravity' 'a' 'a b'\\\\''c d' '--an' '--'" \
	" --cruelty --bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d' '--'" \
	--cruelty --bloo=a --evilness abcd --fury=xyz --depravity a 'a b'\''c d' --an --

__test_section__ 'With some options and arguments and things looking like options after "--"'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --cruelty --bloodlust 'a' --evilness '' 'abcd' --depravity 'a' '--' '--fury=xyz' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '" \
	" --cruelty --bloodlust 'a' --evilness '' --depravity 'a' -- 'abcd' '--fury=xyz' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '" \
	" --cruelty --bloodlust 'a' --evilness '' -- 'abcd' '--depra' 'a' '--' '--fury=xyz' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '" \
	" --cruelty --bloodlust 'a' --evilness '' --depravity 'a' -- 'abcd' '--' '--fury=xyz' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '" \
	--cr --b=a --e abcd --depra a -- --fury=xyz --anger 'a b'\''c d' --deprav as\'\\dfg' '

__test_section__ 'With some options and arguments and a few "--"'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --cruelty --bloodlust 'a' --evilness '' 'abcd' '--' '--f=xyz' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'" \
	" --cruelty --bloodlust 'a' --evilness '' -- 'abcd' '--f=xyz' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'" \
	" --cruelty --bloodlust 'a' --evilness '' -- 'abcd' '--' '--f=xyz' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'" \
	" --cruelty --bloodlust 'a' --evilness '' -- 'abcd' '--' '--f=xyz' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'" \
	--cruelty --blood=a --evil abcd -- --f=xyz --d=a -- --ang 'a b'\''c d' --depravity asdfg --

__test_section__ 'With an option that starts with "-"'
test_get_options_success \
	'' \
	'anger,-bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --cruelty ---bloodlust 'a' --evilness '' 'abcd' --fury 'xyz' --depravity 'a' 'a b'\\\\''c d' --anger" \
	" --cruelty ---bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	" --cruelty ---bloodlust 'a' --evilness '' -- 'abcd' '--f=xyz' '--deprav' 'a' 'a b'\\\\''c d' '--anger'" \
	" --cruelty ---bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	--cruelty ---bl=a --ev abcd --f=xyz --deprav a 'a b'\''c d' --anger

__test_section__ 'With an option that starts with ":"'
test_get_options_success \
	'' \
	'anger,:bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --cruelty --':'bloodlust 'a' --evilness '' 'abcd' --fury 'xyz' --depravity 'a' 'a b'\\\\''c d' --anger" \
	" --cruelty --':'bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	" --cruelty --':'bloodlust 'a' --evilness '' -- 'abcd' '--f=xyz' '--deprav' 'a' 'a b'\\\\''c d' '--anger'" \
	" --cruelty --':'bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	--cruelty --:bl=a --ev abcd --f=xyz --deprav a 'a b'\''c d' --anger

__test_section__ 'With an option that starts with tripple ":"'
test_get_options_success \
	'' \
	'anger,:::bloodlust:,cruelty,depravity:,evilness::,fury::' \
	" --cruelty --':'':'':'bloodlust 'a' --evilness '' 'abcd' --fury 'xyz' --depravity 'a' 'a b'\\\\''c d' --anger" \
	" --cruelty --':'':'':'bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	" --cruelty --':'':'':'bloodlust 'a' --evilness '' -- 'abcd' '--f=xyz' '--deprav' 'a' 'a b'\\\\''c d' '--anger'" \
	" --cruelty --':'':'':'bloodlust 'a' --evilness '' --fury 'xyz' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	--cruelty --:::bl=a --ev abcd --f=xyz --deprav a 'a b'\''c d' --anger
