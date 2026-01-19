. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test
if ! is_facet_active 'long-running'
then
	skip_silently
fi

# The result may be a little overestimated but tests are not the right place for precise calculation.
# The important thing is that it's going to be enough to trigger the (hopefully fixed) error.
single_file_name_length=128
number_of_files=1
while printf "%$((single_file_name_length * number_of_files))s" '' | tr ' ' 'a' | xargs printf '%s\n' 1>/dev/null 2>&1
do
	number_of_files=$((number_of_files * 2))
	if [ "$number_of_files" -gt 9000 ]
	then
		break
	fi
done
if [ "$number_of_files" -gt 9000 ]
then
	known_failure 'The number of files needed to exceed limit of "xargs" is over 9000! It would take too long.'
	exit 1
fi
printf 'Min number of files to exceed limit of "xargs": %i\n' "$number_of_files"

PARAMETRIZE_HEAD_TYPE 'BRANCH'
PARAMETRIZE_CREATE_OPERATION 'push'
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'YES'
PARAMETRIZE_KEEP_INDEX 'NO'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_COLOR YES  # Randomly chosen value

# It's messy enough without those.
rm ignored0 ignored1

__end_of_initialization__

gen_file_names() { # suffix
	current_file_name="$(printf "%$((single_file_name_length - ${#1}))s" '' | tr ' ' 'a')$1"
	x="$number_of_files"
	while [ "$x" -ne 0 ]
	do
		printf '%s\n' "$current_file_name"
		#shellcheck disable=SC2018
		current_file_name="$(printf '%s' "$current_file_name" | sed -E 's/^(z*[a-y]).+$/\1/' | tr 'a-z' 'b-za')$(printf '%s' "$current_file_name" | sed -E 's/^z*[a-y](.+)$/\1/')"
		x=$((x - 1))
	done
}
tracked_files="$(gen_file_names '_tracked')"
untracked_files="$(gen_file_names '_untracked')"

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf '%s\n' "$tracked_files" \
| while read -r file_name
do
	printf 'aaa\n' >"$file_name"
done
printf '%s\n' "$tracked_files" \
| xargs -- git add
printf '%s\n' "$tracked_files" \
| while read -r file_name
do
	printf 'bbb\n' >"$file_name"
done
printf '%s\n' "$untracked_files" \
| while read -r file_name
do
	printf 'ccc\n' >"$file_name"
done
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $UNTRACKED_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $ALL_FLAGS $COLOR_FLAGS --message 'the biggest stash'
assert_outputs__create__success '*' 0 'the biggest stash'
new_stash_sha_CO="$stdout"
assert_files_HT '
'
store_stash_CO "$new_stash_sha_CO"
assert_stash_HT 0 'the biggest stash' "$(
	printf '%s\n' "$tracked_files" | sed -E -e 's/^/AM /' -e 's/$/ bbb aaa/'
	printf '%s\n' "$untracked_files" | sed -E -e 's/^/?? /' -e 's/$/ ccc/'
)"
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 1
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes 1>/dev/null
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git istash pop $COLOR_FLAGS
assert_outputs__apply__success pop 0 "$stash_sha"
assert_files "$(
	printf '%s\n' "$tracked_files" | sed -E -e 's/^/AM /' -e 's/$/ bbb aaa/'
	printf '%s\n' "$untracked_files" | sed -E -e 's/^/?? /' -e 's/$/ ccc/'
)"
assert_stash_count 0
assert_log_length 1
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
