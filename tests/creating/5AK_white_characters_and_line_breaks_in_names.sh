. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'This test requires a file system without limitations for file names.'
fi

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

# We don't need thos in this test.
rm ignored0 ignored1

# Some tracked files to make it harder on the algorithms creating the commit for ignored ones.
__test_section__ 'Prepare repository'
printf 'x\n' >'unc hanged'
printf 'x\n' >'index'
printf 'x\n' >'no
rmal'
printf 'x\n' >'both'
mkdir 'tracked-dir1'
printf 'x\n' >'tracked-dir1/unchanged'
printf 'x\n' >'tracked-dir1/ind ex'
printf 'x\n' >'tracked-dir1/normal'
printf 'x\n' >'tracked-dir1/both'
mkdir 'tracked-dir1/trac
ked-dir2'
printf 'x\n' >'tracked-dir1/trac
ked-dir2/unchanged'
printf 'x\n' >'tracked-dir1/trac
ked-dir2/index'
printf 'x\n' >'tracked-dir1/trac
ked-dir2/normal'
printf 'x\n' >'tracked-dir1/trac
ked-dir2/b

ot   h'
git add .
git commit -m 'Added some files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'y\n' >'index'
printf 'y\n' >'both'
printf 'y\n' >'new'
printf 'y\n' >'changed-new'
printf 'y\n' >'tracked-dir1/ind ex'
printf 'y\n' >'tracked-dir1/both'
printf 'y\n' >'tracked-dir1/new'
printf 'y\n' >'tracked-dir1/changed-new'
printf 'y\n' >'tracked-dir1/trac
ked-dir2/index'
printf 'y\n' >'tracked-dir1/trac
ked-dir2/b

ot   h'
printf 'y\n' >'tracked-dir1/trac
ked-dir2/new'
printf 'y\n' >'tracked-dir1/trac
ked-dir2/changed-new'
git add .
printf 'z\n' >'no
rmal'
printf 'z\n' >'both'
printf 'z\n' >'changed-new'
printf 'z\n' >'tracked-dir1/normal'
printf 'z\n' >'tracked-dir1/both'
printf 'z\n' >'tracked-dir1/changed-new'
printf 'z\n' >'tracked-dir1/trac
ked-dir2/normal'
printf 'z\n' >'tracked-dir1/trac
ked-dir2/b

ot   h'
printf 'z\n' >'tracked-dir1/trac
ked-dir2/changed-new'
# And now the ignored files.
printf 'uf\n' >'ignored file'
mkdir 'untracked-dir1'
printf 'uf0\n' >'untracked-dir1/some-file0'
printf 'uf1\n' >'untracked-dir1/some file1'
printf 'uf\n' >'tracked-dir1/untracked
file'
mkdir 'tracked-dir1/ignored-d

ir2'
printf 'uf0\n' >'tracked-dir1/ignored-d

ir2/some-file0'
printf 'uf1\n' >'tracked-dir1/ignored-d

ir2/some
file1'
printf '%s\n' '*ignored*' >.git/info/exclude
#shellcheck disable=SC2086
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS $UNSTAGED_FLAGS $STAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS
if ! IS_KEEP_INDEX_ON
then
	assert_files_H '
	   unc\040hanged				x
	   index					x
	   no\nrmal					x
	   both						x
	   tracked-dir1/unchanged			x
	   tracked-dir1/ind\040ex			x
	   tracked-dir1/normal				x
	   tracked-dir1/both				x
	   tracked-dir1/trac\nked-dir2/unchanged	x
	   tracked-dir1/trac\nked-dir2/index		x
	   tracked-dir1/trac\nked-dir2/normal		x
	   tracked-dir1/trac\nked-dir2/b\n\not\040\040\040h x
	'
else
	assert_files_H '
	   unc\040hanged				x
	M  index						y
	   no\nrmal					x
	M  both							y
	A  new							y
	A  changed-new						y
	   tracked-dir1/unchanged			x
	M  tracked-dir1/ind\040ex				y
	   tracked-dir1/normal				x
	M  tracked-dir1/both					y
	A  tracked-dir1/new					y
	A  tracked-dir1/changed-new				y
	   tracked-dir1/trac\nked-dir2/unchanged	x
	M  tracked-dir1/trac\nked-dir2/index			y
	   tracked-dir1/trac\nked-dir2/normal		x
	M  tracked-dir1/trac\nked-dir2/b\n\not\040\040\040h	y
	A  tracked-dir1/trac\nked-dir2/new			y
	A  tracked-dir1/trac\nked-dir2/changed-new		y
	'
fi
assert_stash_H 0 '' '
   unc\040hanged				x
M  index						y
 M no\nrmal					z	x
MM both						z	y
A  new							y
AM changed-new					z	y
   tracked-dir1/unchanged			x
M  tracked-dir1/ind\040ex				y
 M tracked-dir1/normal				z	x
MM tracked-dir1/both				z	y
A  tracked-dir1/new					y
AM tracked-dir1/changed-new			z	y
   tracked-dir1/trac\nked-dir2/unchanged	x
M  tracked-dir1/trac\nked-dir2/index			y
 M tracked-dir1/trac\nked-dir2/normal		z	x
MM tracked-dir1/trac\nked-dir2/b\n\not\040\040\040h z	y
A  tracked-dir1/trac\nked-dir2/new			y
AM tracked-dir1/trac\nked-dir2/changed-new	z	y
!! ignored\040file				uf
?? untracked-dir1/some-file0			uf0
?? untracked-dir1/some\040file1			uf1
?? tracked-dir1/untracked\nfile			uf
!! tracked-dir1/ignored-d\n\nir2/some-file0	uf0
!! tracked-dir1/ignored-d\n\nir2/some\nfile1	uf1
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
   unc\040hanged				x
M  index						y
 M no\nrmal					z	x
MM both						z	y
A  new							y
AM changed-new					z	y
   tracked-dir1/unchanged			x
M  tracked-dir1/ind\040ex				y
 M tracked-dir1/normal				z	x
MM tracked-dir1/both				z	y
A  tracked-dir1/new					y
AM tracked-dir1/changed-new			z	y
   tracked-dir1/trac\nked-dir2/unchanged	x
M  tracked-dir1/trac\nked-dir2/index			y
 M tracked-dir1/trac\nked-dir2/normal		z	x
MM tracked-dir1/trac\nked-dir2/b\n\not\040\040\040h z	y
A  tracked-dir1/trac\nked-dir2/new			y
AM tracked-dir1/trac\nked-dir2/changed-new	z	y
!! ignored\040file				uf
?? untracked-dir1/some-file0			uf0
?? untracked-dir1/some\040file1			uf1
?? tracked-dir1/untracked\nfile			uf
!! tracked-dir1/ignored-d\n\nir2/some-file0	uf0
!! tracked-dir1/ignored-d\n\nir2/some\nfile1	uf1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_H
assert_dotgit_contents
