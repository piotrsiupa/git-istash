. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_COLOR 'YES'

__end_of_initialization__

prepare_repository

# Easier to assert this than making this code dynamic.
test "$GIT_CONFIG_COUNT" = 1 \
	|| fail 'Error in test: expected GIT_CONFIG_COUNT to be 1!\n'
GIT_CONFIG_COUNT=3
GIT_CONFIG_KEY_1='color.istash.error.warning'
GIT_CONFIG_VALUE_1='kinda reddish but more royal'
GIT_CONFIG_KEY_2='color.istash.error.normal'
GIT_CONFIG_VALUE_2='silvery transparent sepia'
export GIT_CONFIG_COUNT
export GIT_CONFIG_KEY_1
export GIT_CONFIG_VALUE_1
export GIT_CONFIG_KEY_2
export GIT_CONFIG_VALUE_2
export GIT_CONFIG_KEY_3
export GIT_CONFIG_VALUE_3

SWITCH_HEAD_TYPE

__test_section__ "$CAP_APPLY_OPERATION stash (without changes)"
correct_head_sha="$(get_head_sha_HT)"
#shellcheck disable=SC2086
assert_exit_code 1 git istash "$APPLY_OPERATION" $COLOR_FLAGS
assert_outputs_with_color '' "
	$(create_bad_color_config_value_regex 'kinda reddish but more royal' 'color.istash.error.warning')\\n
	$(create_bad_color_config_value_regex 'silvery transparent sepia' 'color.istash.error.normal')\\n
	$(create_no_such_commit_regex 'stash@{0}')
"
assert_files_HT '
!! ignored0	ignored0
!! ignored1	ignored1
'
assert_stash_count 0
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_data_files 'none'
assert_rebase n
assert_dotgit_contents
