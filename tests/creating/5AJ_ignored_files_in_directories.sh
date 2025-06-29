. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES' 'NO'
PARAMETRIZE_KEEP_INDEX 'DEFAULT'
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

# We don't need thos in this test.
rm ignored0 ignored1

# Some tracked files to make it harder on the algorithms creating the commit for ignored ones.
__test_section__ 'Prepare repository'
printf 'x\n' >unchanged
printf 'x\n' >index
printf 'x\n' >normal
printf 'x\n' >both
mkdir tracked-dir1
printf 'x\n' >tracked-dir1/unchanged
printf 'x\n' >tracked-dir1/index
printf 'x\n' >tracked-dir1/normal
printf 'x\n' >tracked-dir1/both
mkdir tracked-dir1/tracked-dir2
printf 'x\n' >tracked-dir1/tracked-dir2/unchanged
printf 'x\n' >tracked-dir1/tracked-dir2/index
printf 'x\n' >tracked-dir1/tracked-dir2/normal
printf 'x\n' >tracked-dir1/tracked-dir2/both
git add .
git commit -m 'Added some files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'y\n' >index
printf 'y\n' >both
printf 'y\n' >new
printf 'y\n' >changed-new
printf 'y\n' >tracked-dir1/index
printf 'y\n' >tracked-dir1/both
printf 'y\n' >tracked-dir1/new
printf 'y\n' >tracked-dir1/changed-new
printf 'y\n' >tracked-dir1/tracked-dir2/index
printf 'y\n' >tracked-dir1/tracked-dir2/both
printf 'y\n' >tracked-dir1/tracked-dir2/new
printf 'y\n' >tracked-dir1/tracked-dir2/changed-new
git add .
printf 'z\n' >normal
printf 'z\n' >both
printf 'z\n' >changed-new
printf 'z\n' >tracked-dir1/normal
printf 'z\n' >tracked-dir1/both
printf 'z\n' >tracked-dir1/changed-new
printf 'z\n' >tracked-dir1/tracked-dir2/normal
printf 'z\n' >tracked-dir1/tracked-dir2/both
printf 'z\n' >tracked-dir1/tracked-dir2/changed-new
# And now the ignored files.
printf 'uf\n' >ignored-file
mkdir ignored-dir1
printf 'uf0\n' >ignored-dir1/some-file0
printf 'uf1\n' >ignored-dir1/some-file1
printf 'uf\n' >tracked-dir1/ignored-file
mkdir tracked-dir1/ignored-dir2
printf 'uf0\n' >tracked-dir1/ignored-dir2/some-file0
printf 'uf1\n' >tracked-dir1/ignored-dir2/some-file1
printf '%s\n' '*ignored*' >.git/info/exclude
#shellcheck disable=SC2086
new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS)"
assert_files_HTCO '
   unchanged					x
M  index						y
 M normal					z	x
MM both						z	y
A  new							y
AM changed-new					z	y
   tracked-dir1/unchanged			x
M  tracked-dir1/index					y
 M tracked-dir1/normal				z	x
MM tracked-dir1/both				z	y
A  tracked-dir1/new					y
AM tracked-dir1/changed-new			z	y
   tracked-dir1/tracked-dir2/unchanged		x
M  tracked-dir1/tracked-dir2/index			y
 M tracked-dir1/tracked-dir2/normal		z	x
MM tracked-dir1/tracked-dir2/both		z	y
A  tracked-dir1/tracked-dir2/new			y
AM tracked-dir1/tracked-dir2/changed-new	z	y
!! ignored-file					uf
!! ignored-dir1/some-file0			uf0
!! ignored-dir1/some-file1			uf1
!! tracked-dir1/ignored-file			uf
!! tracked-dir1/ignored-dir2/some-file0		uf0
!! tracked-dir1/ignored-dir2/some-file1		uf1
' '
   unchanged					x
   index					x
   normal					x
   both						x
   tracked-dir1/unchanged			x
   tracked-dir1/index				x
   tracked-dir1/normal				x
   tracked-dir1/both				x
   tracked-dir1/tracked-dir2/unchanged		x
   tracked-dir1/tracked-dir2/index		x
   tracked-dir1/tracked-dir2/normal		x
   tracked-dir1/tracked-dir2/both		x
'
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 '' '
   unchanged					x
M  index						y
 M normal					z	x
MM both						z	y
A  new							y
AM changed-new					z	y
   tracked-dir1/unchanged			x
M  tracked-dir1/index					y
 M tracked-dir1/normal				z	x
MM tracked-dir1/both				z	y
A  tracked-dir1/new					y
AM tracked-dir1/changed-new			z	y
   tracked-dir1/tracked-dir2/unchanged		x
M  tracked-dir1/tracked-dir2/index			y
 M tracked-dir1/tracked-dir2/normal		z	x
MM tracked-dir1/tracked-dir2/both		z	y
A  tracked-dir1/tracked-dir2/new			y
AM tracked-dir1/tracked-dir2/changed-new	z	y
!! ignored-file					uf
!! ignored-dir1/some-file0			uf0
!! ignored-dir1/some-file1			uf1
!! tracked-dir1/ignored-file			uf
!! tracked-dir1/ignored-dir2/some-file0		uf0
!! tracked-dir1/ignored-dir2/some-file1		uf1
'
assert_stash_base_HT 0 'HEAD'
assert_stash_count 1
assert_log_length_HT 2
assert_branch_count 1
assert_head_hash_HT "$correct_head_hash"
assert_head_name_HT
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents

remove_all_changes
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
   unchanged					x
M  index						y
 M normal					z	x
MM both						z	y
A  new							y
AM changed-new					z	y
   tracked-dir1/unchanged			x
M  tracked-dir1/index					y
 M tracked-dir1/normal				z	x
MM tracked-dir1/both				z	y
A  tracked-dir1/new					y
AM tracked-dir1/changed-new			z	y
   tracked-dir1/tracked-dir2/unchanged		x
M  tracked-dir1/tracked-dir2/index			y
 M tracked-dir1/tracked-dir2/normal		z	x
MM tracked-dir1/tracked-dir2/both		z	y
A  tracked-dir1/tracked-dir2/new			y
AM tracked-dir1/tracked-dir2/changed-new	z	y
!! ignored-file					uf
!! ignored-dir1/some-file0			uf0
!! ignored-dir1/some-file1			uf1
!! tracked-dir1/ignored-file			uf
!! tracked-dir1/ignored-dir2/some-file0		uf0
!! tracked-dir1/ignored-dir2/some-file1		uf1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
