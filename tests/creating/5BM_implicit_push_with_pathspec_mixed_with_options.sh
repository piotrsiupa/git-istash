. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL
PARAMETRIZE_UNTRACKED 'YES' 'NO'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE 'ARGS'
PARAMETRIZE_OPTIONS_INDICATOR true

__test_section__ 'Prepare repository'
printf 'xxx\n' >aaa0
printf 'xxx\n' >aaa1
printf 'xxx\n' >bbb2
printf 'xxx\n' >bbb3
printf 'xxx\n' >ccc4
printf 'xxx\n' >ccc5
printf 'xxx\n' >ddd6
printf 'xxx\n' >ddd7
printf 'xxx\n' >eee8
printf 'xxx\n' >eee9
git add .
git commit -m 'Added a bunch of files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'yyy\n' >aaa0
printf 'yyy\n' >aaa1
printf 'yyy\n' >bbb2
printf 'yyy\n' >bbb3
printf 'yyy\n' >ccc4
printf 'yyy\n' >ccc5
printf 'yyy\n' >ddd6
printf 'yyy\n' >ddd7
printf 'yyy\n' >eee8
printf 'yyy\n' >eee9
git add aaa0 bbb2 ccc4 ddd6 eee8
printf 'zzz\n' >bbb2
printf 'zzz\n' >ccc4
#shellcheck disable=SC2086
assert_exit_code 1 git istash $UNTRACKED_FLAGS $ALL_FLAGS 'aaa0' $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS 'bbb?' -m 'new stash' $EOI '*5' './?dd*'
assert_files_HT '
M  aaa0		yyy
 M aaa1		yyy	xxx
MM bbb2		zzz	yyy
 M bbb3		yyy	xxx
MM ccc4		zzz	yyy
 M ccc5		yyy	xxx
M  ddd6		yyy
 M ddd7		yyy	xxx
M  eee8		yyy
 M eee9		yyy	xxx
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
