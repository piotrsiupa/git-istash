. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_GET_OPTIONS_MODE

__end_of_initialization__

cd - 1>/dev/null
. ../lib/git-istash/get_options
cd - 1>/dev/null

__test_section__ 'Without arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	"" \
	" --" \
	

__test_section__ 'Without only --'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" '--'" \
	" --" \
	--

__test_section__ 'With an argument'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" 'anger'" \
	" -- 'anger'" \
	anger

__test_section__ 'With an option'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --anger" \
	" --anger --" \
	--anger

__test_section__ 'With an option with a parameter'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --bloodlust ' xyz '" \
	" --bloodlust ' xyz ' --" \
	--bloodlust ' xyz '

__test_section__ 'With an option with an empty parameter'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --bloodlust ''" \
	" --bloodlust '' --" \
	--bloodlust ''

__test_section__ 'With an option with a parameter separated by "="'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --bloodlust ' xyz '" \
	" --bloodlust ' xyz ' --" \
	--bloodlust=' xyz '

__test_section__ 'With an option with an empty parameter separated by "="'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --bloodlust ''" \
	" --bloodlust '' --" \
	--bloodlust=

__test_section__ 'With a few options'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --bloodlust ' xyz ' --cruelty --depravity 'a'" \
	" --bloodlust ' xyz ' --cruelty --depravity 'a' --" \
	--bloodlust ' xyz ' --cruelty --depravity=a

__test_section__ 'With a few repeated options'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --bloodlust ' xyz ' --cruelty --depravity '--anger' --bloodlust 'qwerty' --anger --cruelty" \
	" --bloodlust ' xyz ' --cruelty --depravity '--anger' --bloodlust 'qwerty' --anger --cruelty --" \
	--bloodlust ' xyz ' --cruelty --depravity --anger --bloodlust qwerty --anger --cruelty

__test_section__ 'With a few abbreviated options'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --bloodlust ' xyz ' --cruelty --depravity 'a'" \
	" --bloodlust ' xyz ' --cruelty --depravity 'a' --" \
	--blood ' xyz ' --cruelt --d=a

__test_section__ 'With a few abbreviation that is a name of a different option'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,blood,depravity:' \
	" --bloodlust ' xyz ' --cruelty --blood --depravity 'a'" \
	" --bloodlust ' xyz ' --cruelty --blood --depravity 'a' --" \
	--bloodl ' xyz ' --cruelt --blood --d=a

__test_section__ 'With some options and arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --cruelty --bloodlust 'a' 'abcd' --depravity 'a' 'a b'\\\\''c d' --anger" \
	" --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	--cruelty --bl=a abcd --deprav a 'a b'\''c d' --anger

__test_section__ 'With some options and arguments and "--" before arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --cruelty --bloodlust 'a' --depravity 'a' --anger '--' 'abcd' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	--cruelty --bloodlust=a --depravity a --ang -- abcd 'a b'\''c d'

__test_section__ 'With some options and arguments and "--" in middle of arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --cruelty --bloodlust 'a' 'abcd' --depravity 'a' --anger '--' 'a b'\\\\''c d'" \
	" --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	--cruelty --bloodlust=a abcd --depr a --anger -- 'a b'\''c d'

__test_section__ 'With some options and arguments and "--" after arguments'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --cruelty --bloodlust 'a' 'abcd' --depravity 'a' 'a b'\\\\''c d' --anger '--'" \
	" --cruelty --bloodlust 'a' --depravity 'a' --anger -- 'abcd' 'a b'\\\\''c d'" \
	--cruelty --bloo=a abcd --depravity a 'a b'\''c d' --an --

__test_section__ 'With some options and arguments and things looking like options after "--"'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --cruelty --bloodlust 'a' 'abcd' --depravity 'a' '--' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '" \
	" --cruelty --bloodlust 'a' --depravity 'a' -- 'abcd' '--anger' 'a b'\\\\''c d' '--deprav' 'as'\\\\''\\\\dfg '" \
	--cr --b=a abcd --depra a -- --anger 'a b'\''c d' --deprav as\'\\dfg' '

__test_section__ 'With some options and arguments and a few "--"'
test_get_options_success \
	'' \
	'anger,bloodlust:,cruelty,depravity:' \
	" --cruelty --bloodlust 'a' 'abcd' '--' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'" \
	" --cruelty --bloodlust 'a' -- 'abcd' '--d=a' '--' '--ang' 'a b'\\\\''c d' '--depravity' 'asdfg' '--'" \
	--cruelty --blood=a abcd -- --d=a -- --ang 'a b'\''c d' --depravity asdfg --
