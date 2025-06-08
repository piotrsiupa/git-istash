# BE VERY CAREFULL EDITING THIS FILE!
# There is a good chance your editor will mangle the characters used here.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'This test requires a file system without limitations for file names.'
fi

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

__test_section__ 'Prepare repository'
printf 'aaa1\n' >'bo	=ÿþ€{a}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'bbb1\n' >'bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'ccc1\n' >'bo	=ÿþ€{c}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'ddd1\n' >'bo	=ÿþ€{d}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add 'bo	=ÿþ€{a}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th' 'bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th' 'bo	=ÿþ€{c}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th' 'bo	=ÿþ€{d}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git commit -m 'Added some files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'aaa2\n' >'bo	=ÿþ€{a}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'bbb2\n' >'bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add 'bo	=ÿþ€{a}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th' 'bo	=ÿþ€{b}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'ccc2\n' >'bo	=ÿþ€{c}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'ddd2\n' >'bo	=ÿþ€{d}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'eee2\n' >'bo	=ÿþ€{e}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'fff2\n' >'bo	=ÿþ€{f}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'e n e n ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
GIT_EDITOR="sed -Ei 's/^\+[a-z]{3}2/+xxx/'" assert_exit_code 0 git istash push $UNTRACKED_FLAGS $ALL_FLAGS --patch $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS <.git/answers_for_patch
if ! IS_KEEP_INDEX_ON
then
	assert_files_HT '
	   bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{a}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th aaa1
	   bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{b}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th bbb1
	 M bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{c}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th ccc2 ccc1
	 M bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{d}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th ddd2 ddd1
	?? bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{e}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th eee2
	?? bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{f}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th fff2
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
else
	assert_files_HT '
	M  bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{a}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th aaa2
	M  bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{b}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th bbb2
	 M bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{c}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th ccc2 ccc1
	 M bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{d}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th ddd2 ddd1
	?? bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{e}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th eee2
	?? bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{f}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th fff2
	!! ignored0	ignored0
	!! ignored1	ignored1
	'
fi
assert_stash_HT 0 '' '
M  bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{a}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th aaa2
M  bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{b}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th bbb2
 M bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{c}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th xxx ccc1
   bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{d}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th ddd1
?? bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{e}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th xxx
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes
git clean -df
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
M  bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{a}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th aaa2
M  bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{b}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th bbb2
 M bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{c}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th xxx ccc1
   bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{d}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th ddd1
?? bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{e}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th xxx
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
