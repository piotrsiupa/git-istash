# BE VERY CAREFULL EDITING THIS FILE!
# There is a good chance your editor will mangle the characters used here.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'This test requires a file system without limitations for file names.'
fi

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

# We don't need thos in this test.
rm ignored0 ignored1

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'x\n' >'file'
printf 'x\n' >'bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
mkdir 'tra	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©cked-dir1'
printf 'x\n' >'tra	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©cked-dir1/file'
printf 'x\n' >'tra	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©cked-dir1/bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
mkdir 'tra	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©cked-dir1/tracked-dir2'
printf 'x\n' >'tra	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©cked-dir1/tracked-dir2/file'
printf 'x\n' >'tra	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©cked-dir1/tracked-dir2/bo	=ÿþ€{}\*?#@![1;35;4;5m|:<>()^&[0mðŸ’©th'
git add --intent-to-add .
#shellcheck disable=SC2086
new_stash_sha_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS)"
assert_files_HTCO '
 A file						x
 A bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/file x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/tracked-dir2/file x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/tracked-dir2/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th x
' '
'
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
 A file						x
 A bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/file x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/tracked-dir2/file x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/tracked-dir2/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th x
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git istash pop
assert_files '
 A file						x
 A bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/file x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/tracked-dir2/file x
 A tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251cked-dir1/tracked-dir2/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!\033[1;35;4;5m|:<>()^&\033[0m\360\237\222\251th x
'
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
