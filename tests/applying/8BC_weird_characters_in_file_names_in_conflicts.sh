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
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
printf 'foo\n' >'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add 'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git commit -m 'Added a file'

__test_section__ 'Create stash'
printf 'bar\n' >'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add 'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'baz\n' >'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'zzz\n' >'bo	=ÿþ€{2}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git stash push -u

__test_section__ 'Create conflict'
printf 'qux\n' >'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
printf 'yyy\n' >'bo	=ÿþ€{2}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add 'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th' 'bo	=ÿþ€{2}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git commit -m 'Changed the first file & added a second one'

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_hash="$(get_head_hash_HT)"
assert_exit_code 2 capture_outputs git istash "$APPLY_OPERATION"
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th qux|bar
   bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{2}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th yyy
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (0)"
printf 'quux\n' >'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add 'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
assert_exit_code 2 capture_outputs git istash "$APPLY_OPERATION" --continue
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
UU bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th quux|baz
   bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{2}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th yyy
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (1)"
printf 'fff\n' >'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add 'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
assert_exit_code 2 capture_outputs git istash "$APPLY_OPERATION" --continue
assert_conflict_message "$APPLY_OPERATION"
assert_files_HT '
   bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th fff
AA bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{2}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th yyy|zzz
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (2)"
printf 'xxx\n' >'bo	=ÿþ€{2}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add 'bo	=ÿþ€{2}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
assert_exit_code 0 git istash "$APPLY_OPERATION" --continue
assert_files_HT '
MM bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th fff	quux
 M bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{2}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th xxx	yyy
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 3
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
