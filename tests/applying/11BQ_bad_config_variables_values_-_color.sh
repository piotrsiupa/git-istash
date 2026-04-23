. "$(dirname "$0")/../commons.sh" 1>/dev/null

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_COLOR 'YES'
PARAMETRIZE_SUMMARY 'COMPL'

__end_of_initialization__

prepare_repository

# Easier to assert this than making this code dynamic.
test "$GIT_CONFIG_COUNT" = 1 \
	|| fail 'Error in test: expected GIT_CONFIG_COUNT to be 1!\n'
GIT_CONFIG_COUNT=4
GIT_CONFIG_KEY_1='color.istash.error.warning'
GIT_CONFIG_VALUE_1='silvery transparent sepia'
GIT_CONFIG_KEY_2='color.istash.summary.updated'
GIT_CONFIG_VALUE_2='a little goldish but better'
GIT_CONFIG_KEY_3='istash.summary'
GIT_CONFIG_VALUE_3='print literally everything'
export GIT_CONFIG_COUNT
export GIT_CONFIG_KEY_1
export GIT_CONFIG_VALUE_1
export GIT_CONFIG_KEY_2
export GIT_CONFIG_VALUE_2
export GIT_CONFIG_KEY_3
export GIT_CONFIG_VALUE_3
export GIT_CONFIG_KEY_4
export GIT_CONFIG_VALUE_4

__test_section__ 'Prepare repository'
printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

__test_section__ 'Create stash'
printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
printf 'ddd\n' >ddd
git stash push -u

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$APPLY_OPERATION" --color=always
assert_outputs__apply__success "$APPLY_OPERATION" '
MM aaa
?A ddd
' 0 "$stash_sha" "
	$(create_bad_color_config_value_regex 'silvery transparent sepia' 'color.istash.error.warning')\\n
	$(create_bad_summary_mode_regex 'print literally everything')\\n
	$(create_bad_color_config_value_regex 'a little goldish but better' 'color.istash.summary.updated')
"
assert_files_HT '
MM aaa		ccc	bbb
?? ddd		ddd
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
