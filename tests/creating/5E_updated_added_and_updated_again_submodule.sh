. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'DEFAULT'
PARAMETRIZE_UNTRACKED 'DEFAULT'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'
PARAMETRIZE_COLOR
PARAMETRIZE_QUIET

__end_of_initialization__

prepare_repository

__test_section__ 'Prepare repository'
printf 'aaa1\n' >aaa
printf 'bbb1\n' >bbb
printf 'ccc1\n' >ccc
printf 'ddd1\n' >ddd
git add aaa bbb ccc ddd
git -c protocol.file.allow=always submodule add -b my-branch "$(dirname "$(dirname "$(dirname "$(pwd)")")")/remote-for-tests" the-sub-mod
printf 'bbb\n' >the-sub-mod/aaa
git -C the-sub-mod add aaa
printf 'ccc\n' >the-sub-mod/aaa
git commit -m 'Added aaa, bbb, ccc, ddd & a submodule'

cd the-sub-mod
old_correct_sub_mod_head_sha="$(get_head_sha)"
cd -

correct_head_sha="$(get_head_sha)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'aaa2\n' >aaa
printf 'bbb2\n' >bbb
git add aaa bbb
printf 'bbb3\n' >bbb
printf 'ddd3\n' >ddd
git submodule set-branch --branch other-branch the-sub-mod
git -c protocol.file.allow=always submodule update --remote the-sub-mod
cd the-sub-mod
middle_correct_sub_mod_head_sha="$(get_head_sha)"
cd -
git add .gitmodules the-sub-mod
git submodule set-branch --branch third-branch the-sub-mod
git -c protocol.file.allow=always submodule update --remote the-sub-mod
cd the-sub-mod
new_correct_sub_mod_head_sha="$(get_head_sha)"
cd -
#shellcheck disable=SC2086
assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $ALL_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $UNTRACKED_FLAGS $COLOR_FLAGS $QUIET_FLAGS
assert_outputs__create__success '*' 0 ''
new_stash_sha_CO="$stdout"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	M  aaa			aaa2
	MM bbb		bbb3	bbb2
	   ccc		ccc1
	 M ddd		ddd3	ddd1
	!! ignored0	ignored0
	!! ignored1	ignored1
	MM .gitmodules	[submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040third-branch [submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040other-branch
	#X the-sub-mod	'"$new_correct_sub_mod_head_sha $middle_correct_sub_mod_head_sha"'
	## the-sub-mod/aaa
	## the-sub-mod/xxx
	## the-sub-mod/yyy
	' '
	   aaa		aaa1
	   bbb		bbb1
	   ccc		ccc1
	   ddd		ddd1
	!! ignored0	ignored0
	!! ignored1	ignored1
	   .gitmodules	[submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040my-branch
	#m the-sub-mod	'"$new_correct_sub_mod_head_sha $old_correct_sub_mod_head_sha"'
	## the-sub-mod/aaa
	## the-sub-mod/xxx
	## the-sub-mod/yyy
	'
else
	assert_files_HTCO '
	M  aaa			aaa2
	MM bbb		bbb3	bbb2
	   ccc		ccc1
	 M ddd		ddd3	ddd1
	!! ignored0	ignored0
	!! ignored1	ignored1
	MM .gitmodules	[submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040third-branch [submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040other-branch
	#X the-sub-mod	'"$new_correct_sub_mod_head_sha $middle_correct_sub_mod_head_sha"'
	## the-sub-mod/aaa
	## the-sub-mod/xxx
	## the-sub-mod/yyy
	' '
	M  aaa		aaa2
	M  bbb		bbb2
	   ccc		ccc1
	   ddd		ddd1
	!! ignored0	ignored0
	!! ignored1	ignored1
	M  .gitmodules	[submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040other-branch
	#X the-sub-mod	'"$new_correct_sub_mod_head_sha $middle_correct_sub_mod_head_sha"'
	## the-sub-mod/aaa
	## the-sub-mod/xxx
	## the-sub-mod/yyy
	'
fi
store_stash_CO "$new_stash_sha_CO"
assert_stash_HTCO 0 '' '
M  aaa			aaa2
MM bbb		bbb3	bbb2
   ccc		ccc1
 M ddd		ddd3	ddd1
MM .gitmodules	[submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040third-branch [submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040other-branch
#X the-sub-mod '"$new_correct_sub_mod_head_sha $middle_correct_sub_mod_head_sha"'
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_sha_HT "$correct_head_sha"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
(
	set -eu
	cd the-sub-mod
	assert_files '
	MM aaa	ccc bbb
	   xxx	xxx
	   yyy	yyy
	'
	assert_stash_count 0
	assert_log_length 3
	assert_branch_count 1
	assert_head_sha "$new_correct_sub_mod_head_sha"
	assert_head_name 'HEAD'
	assert_rebase n
	assert_dotgit_contents
)

remove_all_changes
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
M  aaa			aaa2
MM bbb		bbb3	bbb2
   ccc		ccc1
 M ddd		ddd3	ddd1
MM .gitmodules	[submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040third-branch [submodule\040"the-sub-mod"]\n\tpath\040=\040the-sub-mod\n\turl\040=\040'"$(dirname "$(dirname "$(dirname "$(pwd)")")")"'/remote-for-tests\n\tbranch\040=\040other-branch
#X the-sub-mod	'"$new_correct_sub_mod_head_sha $middle_correct_sub_mod_head_sha"'
## the-sub-mod/aaa
## the-sub-mod/xxx
## the-sub-mod/yyy
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_sha "$correct_head_sha"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
(
	set -eu
	cd the-sub-mod
	assert_files '
	MM aaa	ccc bbb
	   xxx	xxx
	   yyy	yyy
	'
	assert_stash_count 0
	assert_log_length 3
	assert_branch_count 1
	assert_head_sha "$new_correct_sub_mod_head_sha"
	assert_head_name 'HEAD'
	assert_rebase n
	assert_dotgit_contents
)
