. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION

__test_section__ 'Prepare repository'
printf 'aaa\nbbb\nccc\nddd\n' >.gitignore
git add .gitignore
git commit -m 'Added .gitignore'

__test_section__ 'Create stash'
printf 'aaa\nbbb\nccc\nyyy\n' >.gitignore
printf 'aaa\n' >aaa
printf 'zzz\n' >zzz
git stash push -ua

SWITCH_HEAD_TYPE

__test_section__ 'Dirty the working directory'
printf 'zzz\nbbb\nccc\nddd\n' >.gitignore
printf 'ddd\n' >ddd
printf 'yyy\n' >yyy

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
stash_sha="$(git rev-parse stash)"
assert_exit_code 0 git istash "$APPLY_OPERATION"
assert_outputs__apply__success "$APPLY_OPERATION" 0 "$stash_sha"
assert_files_HT '
 M .gitignore	zzz\nbbb\nccc\nyyy	aaa\nbbb\nccc\nddd
?? aaa		aaa
?? ddd		ddd
!! yyy		yyy
!! zzz		zzz
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count_AO 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
