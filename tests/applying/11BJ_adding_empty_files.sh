. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_COLOR

__end_of_initialization__

prepare_repository
printf 'ccc\n' >>.git/info/exclude
rm ignored0 ignored1

__test_section__ 'Create stash'
touch aaa
git add aaa
touch bbb
touch ccc
git stash push -ua

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$APPLY_OPERATION" $COLOR_FLAGS
assert_outputs__apply__success "$APPLY_OPERATION" '
A  aaa
?A bbb
!A ccc
' 0 "$stash_sha"
assert_files '
A  aaa	""
?? bbb	""
!! ccc	""
'
assert_stash_count_AO 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
