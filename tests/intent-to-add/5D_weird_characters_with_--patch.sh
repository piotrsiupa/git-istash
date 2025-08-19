# BE VERY CAREFULL EDITING THIS FILE!
# There is a good chance your editor will mangle the characters used here.

. "$commons_path" 1>/dev/null

non_essential_test

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'This test requires a file system without limitations for file names.'
fi

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'eee\n' >'bo	=ÿþ€{e}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'fff\n' >'bo	=ÿþ€{f}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add -N .
printf 'y n ' | tr ' ' '\n' >.git/answers_for_patch
#shellcheck disable=SC2086
new_stash_hash_CO="$(GIT_EDITOR="sed -Ei 's/^\+[a-z]{3}2/+xxx/'" assert_exit_code 0 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS --patch $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS <.git/answers_for_patch)"
assert_files_HTCO '
 A bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{e}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th eee
 A bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{f}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th fff
!! ignored0	ignored0
!! ignored1	ignored1
' '
 A bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{f}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th fff
!! ignored0	ignored0
!! ignored1	ignored1
'
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 '' '
 A bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{e}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th eee
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 1
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
assert_exit_code 0 git istash pop
assert_files '
 A bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{e}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th eee
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
