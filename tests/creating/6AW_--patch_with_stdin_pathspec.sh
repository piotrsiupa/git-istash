# (This situation is also known as "patchspec", I've decided.)

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_PATHSPEC_STYLE 'STDIN' 'NULL-STDIN'
PARAMETRIZE_OPTIONS_INDICATOR IS_PATHSPEC_IN_ARGS

__test_section__ 'Prepare repository'
printf 'xxx\nxxx\n' >aaa0
printf 'xxx\nxxx\n' >aaa1
printf 'xxx\nxxx\n' >bbb2
printf 'xxx\nxxx\n' >bbb3
printf 'xxx\nxxx\n' >ccc4
printf 'xxx\nxxx\n' >ccc5
printf 'xxx\nxxx\n' >ddd6
printf 'xxx\nxxx\n' >ddd7
printf 'xxx\nxxx\n' >eee8
printf 'xxx\nxxx\n' >eee9
git add .
git commit -m 'Added a bunch of files'

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'yyy\nxxx\nxxx\nyyy\n' >aaa0
printf 'yyy\nxxx\nxxx\nyyy\n' >aaa1
printf 'yyy\nxxx\nxxx\nyyy\n' >bbb2
printf 'yyy\nxxx\nxxx\nyyy\n' >bbb3
printf 'yyy\nxxx\nxxx\nyyy\n' >ccc4
printf 'yyy\nxxx\nxxx\nyyy\n' >ccc5
printf 'yyy\nxxx\nxxx\nyyy\n' >ddd6
printf 'yyy\nxxx\nxxx\nyyy\n' >eee8
printf 'yyy\nxxx\nxxx\nyyy\n' >eee9
printf 'yyy\nyyy\n' >fff10
printf 'yyy\nyyy\n' >fff11
git add aaa0 bbb2 ccc4 ddd6 eee8
printf 'zzz\nxxx\nxxx\nzzz\n' >ccc4
rm bbb2 ddd7
printf 'y s y n s n y n y n ' | tr ' ' '\n' >.git/patchspec_for_test
printf 'aaa0 bbb? *5 ./?dd* fff1? ' | PREPARE_PATHSPEC_FILE
#shellcheck disable=SC2086
assert_exit_code 1 git istash "$CREATE_OPERATION" $UNTRACKED_FLAGS $ALL_FLAGS $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS -m 'a very controlled stash' --patch $PATHSPEC_NULL_FLAGS --pathspec-from-file=- <.git/patchspec_for_test
#shellcheck disable=SC2016
assert_outputs '
' '
	Stdin cannot be assigned to both `--patch` and the pathspec\.
'
assert_files_HT '
M  aaa0		yyy\nxxx\nxxx\nyyy
 M aaa1		yyy\nxxx\nxxx\nyyy	xxx\nxxx
MD bbb2		yyy\nxxx\nxxx\nyyy
 M bbb3		yyy\nxxx\nxxx\nyyy	xxx\nxxx
MM ccc4		zzz\nxxx\nxxx\nzzz	yyy\nxxx\nxxx\nyyy
 M ccc5		yyy\nxxx\nxxx\nyyy	xxx\nxxx
M  ddd6		yyy\nxxx\nxxx\nyyy
 D ddd7		xxx\nxxx
M  eee8		yyy\nxxx\nxxx\nyyy
 M eee9		yyy\nxxx\nxxx\nyyy	xxx\nxxx
?? fff10	yyy\nyyy
?? fff11	yyy\nyyy
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
