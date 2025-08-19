. "$commons_path" 1>/dev/null

non_essential_test

#shellcheck disable=SC2154
if [ "$limited_file_system" = y ]
then
	known_failure 'This test requires a file system without limitations for file names.'
fi

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_CREATE_OPERATION
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES'
PARAMETRIZE_KEEP_INDEX
PARAMETRIZE_STAGED 'YES'
PARAMETRIZE_UNSTAGED 'YES'

# We don't need thos in this test.
rm ignored0 ignored1

# Some tracked files to make it harder on the algorithms creating the commit for ignored ones.
__test_section__ 'Prepare repository'
printf 'x\n' >' unchanged '
printf 'x\n' >'index'
printf 'x\n' >'normal
'
printf 'x\n' >'

both'
mkdir 'tracked-dir1 '
printf 'x\n' >'tracked-dir1 /unchanged '
printf 'x\n' >'tracked-dir1 /index '
printf 'x\n' >'tracked-dir1 /normal '
printf 'x\n' >'tracked-dir1 /both   '
mkdir 'tracked-dir1 /
tracked-dir2'
printf 'x\n' >'tracked-dir1 /
tracked-dir2/unchanged'
printf 'x\n' >'tracked-dir1 /
tracked-dir2/ index '
printf 'x\n' >'tracked-dir1 /
tracked-dir2/normal'
printf 'x\n' >'tracked-dir1 /
tracked-dir2/
both

'
git add .
git commit -m 'Added some files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ "$CAP_CREATE_OPERATION stash"
printf 'y\n' >'index'
printf 'y\n' >'

both'
printf 'y\n' >'
new '
printf 'y\n' >' changed-new
'
printf 'y\n' >'tracked-dir1 /index '
printf 'y\n' >'tracked-dir1 /both   '
printf 'y\n' >'tracked-dir1 /new '
printf 'y\n' >'tracked-dir1 / changed-new '
printf 'y\n' >'tracked-dir1 /
tracked-dir2/ index '
printf 'y\n' >'tracked-dir1 /
tracked-dir2/
both

'
printf 'y\n' >'tracked-dir1 /
tracked-dir2/new'
printf 'y\n' >'tracked-dir1 /
tracked-dir2/ changed-new '
git add .
printf 'z\n' >'normal
'
printf 'z\n' >'

both'
printf 'z\n' >' changed-new
'
printf 'z\n' >'tracked-dir1 /normal '
printf 'z\n' >'tracked-dir1 /both   '
printf 'z\n' >'tracked-dir1 / changed-new '
printf 'z\n' >'tracked-dir1 /
tracked-dir2/normal'
printf 'z\n' >'tracked-dir1 /
tracked-dir2/
both

'
printf 'z\n' >'tracked-dir1 /
tracked-dir2/ changed-new '
# And now the ignored files.
printf 'uf\n' >' ignored-file '
mkdir 'untracked-dir1 '
printf 'uf0\n' >'untracked-dir1 / some-file0'
printf 'uf1\n' >'untracked-dir1 / some-file1 '
printf 'uf\n' >'tracked-dir1 /untracked-file '
mkdir 'tracked-dir1 /
ignored-dir2'
printf 'uf0\n' >'tracked-dir1 /
ignored-dir2/some-file0'
printf 'uf1\n' >'tracked-dir1 /
ignored-dir2/ some-file1   '
printf '%s\n' '*ignored*' >.git/info/exclude
#shellcheck disable=SC2086
new_stash_hash_CO="$(assert_exit_code 0 git istash "$CREATE_OPERATION" $KEEP_INDEX_FLAGS $STAGED_FLAGS $UNSTAGED_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS)"
if ! IS_KEEP_INDEX_ON
then
	assert_files_HTCO '
	   \040unchanged\040				x
	M  index						y
	 M normal\n					z	x
	MM \n\nboth					z	y
	A  \nnew\040						y
	AM \040changed-new\n				z	y
	   tracked-dir1\040/unchanged\040		x
	M  tracked-dir1\040/index\040				y
	 M tracked-dir1\040/normal\040			z	x
	MM tracked-dir1\040/both\040\040\040		z	y
	A  tracked-dir1\040/new\040				y
	AM tracked-dir1\040/\040changed-new\040		z	y
	   tracked-dir1\040/\ntracked-dir2/unchanged	x
	M  tracked-dir1\040/\ntracked-dir2/\040index\040	y
	 M tracked-dir1\040/\ntracked-dir2/normal	z	x
	MM tracked-dir1\040/\ntracked-dir2/\nboth\n\n	z	y
	A  tracked-dir1\040/\ntracked-dir2/new			y
	AM tracked-dir1\040/\ntracked-dir2/\040changed-new\040 z	y
	!! \040ignored-file\040				uf
	?? untracked-dir1\040/\040some-file0		uf0
	?? untracked-dir1\040/\040some-file1\040	uf1
	?? tracked-dir1\040/untracked-file\040		uf
	!! tracked-dir1\040/\nignored-dir2/some-file0	uf0
	!! tracked-dir1\040/\nignored-dir2/\040some-file1\040\040\040 uf1
	' '
	   \040unchanged\040				x
	   index					x
	   normal\n					x
	   \n\nboth					x
	   tracked-dir1\040/unchanged\040		x
	   tracked-dir1\040/index\040			x
	   tracked-dir1\040/normal\040			x
	   tracked-dir1\040/both\040\040\040		x
	   tracked-dir1\040/\ntracked-dir2/unchanged	x
	   tracked-dir1\040/\ntracked-dir2/\040index\040 x
	   tracked-dir1\040/\ntracked-dir2/normal	x
	   tracked-dir1\040/\ntracked-dir2/\nboth\n\n	x
	'
else
	assert_files_HTCO '
	   \040unchanged\040				x
	M  index						y
	 M normal\n					z	x
	MM \n\nboth					z	y
	A  \nnew\040						y
	AM \040changed-new\n				z	y
	   tracked-dir1\040/unchanged\040		x
	M  tracked-dir1\040/index\040				y
	 M tracked-dir1\040/normal\040			z	x
	MM tracked-dir1\040/both\040\040\040		z	y
	A  tracked-dir1\040/new\040				y
	AM tracked-dir1\040/\040changed-new\040		z	y
	   tracked-dir1\040/\ntracked-dir2/unchanged	x
	M  tracked-dir1\040/\ntracked-dir2/\040index\040	y
	 M tracked-dir1\040/\ntracked-dir2/normal	z	x
	MM tracked-dir1\040/\ntracked-dir2/\nboth\n\n	z	y
	A  tracked-dir1\040/\ntracked-dir2/new			y
	AM tracked-dir1\040/\ntracked-dir2/\040changed-new\040 z	y
	!! \040ignored-file\040				uf
	?? untracked-dir1\040/\040some-file0		uf0
	?? untracked-dir1\040/\040some-file1\040	uf1
	?? tracked-dir1\040/untracked-file\040		uf
	!! tracked-dir1\040/\nignored-dir2/some-file0	uf0
	!! tracked-dir1\040/\nignored-dir2/\040some-file1\040\040\040 uf1
	' '
	   \040unchanged\040				x
	M  index						y
	   normal\n					x
	M  \n\nboth						y
	A  \nnew\040						y
	A  \040changed-new\n					y
	   tracked-dir1\040/unchanged\040		x
	M  tracked-dir1\040/index\040				y
	   tracked-dir1\040/normal\040			x
	M  tracked-dir1\040/both\040\040\040			y
	A  tracked-dir1\040/new\040				y
	A  tracked-dir1\040/\040changed-new\040			y
	   tracked-dir1\040/\ntracked-dir2/unchanged	x
	M  tracked-dir1\040/\ntracked-dir2/\040index\040	y
	   tracked-dir1\040/\ntracked-dir2/normal	x
	M  tracked-dir1\040/\ntracked-dir2/\nboth\n\n		y
	A  tracked-dir1\040/\ntracked-dir2/new			y
	A  tracked-dir1\040/\ntracked-dir2/\040changed-new\040	y
	'
fi
store_stash_CO "$new_stash_hash_CO"
assert_stash_HTCO 0 '' '
   \040unchanged\040				x
M  index						y
 M normal\n					z	x
MM \n\nboth					z	y
A  \nnew\040						y
AM \040changed-new\n				z	y
   tracked-dir1\040/unchanged\040		x
M  tracked-dir1\040/index\040				y
 M tracked-dir1\040/normal\040			z	x
MM tracked-dir1\040/both\040\040\040		z	y
A  tracked-dir1\040/new\040				y
AM tracked-dir1\040/\040changed-new\040		z	y
   tracked-dir1\040/\ntracked-dir2/unchanged	x
M  tracked-dir1\040/\ntracked-dir2/\040index\040	y
 M tracked-dir1\040/\ntracked-dir2/normal	z	x
MM tracked-dir1\040/\ntracked-dir2/\nboth\n\n	z	y
A  tracked-dir1\040/\ntracked-dir2/new			y
AM tracked-dir1\040/\ntracked-dir2/\040changed-new\040 z	y
!! \040ignored-file\040				uf
?? untracked-dir1\040/\040some-file0		uf0
?? untracked-dir1\040/\040some-file1\040	uf1
?? tracked-dir1\040/untracked-file\040		uf
!! tracked-dir1\040/\nignored-dir2/some-file0	uf0
!! tracked-dir1\040/\nignored-dir2/\040some-file1\040\040\040 uf1
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
   \040unchanged\040				x
M  index						y
 M normal\n					z	x
MM \n\nboth					z	y
A  \nnew\040						y
AM \040changed-new\n				z	y
   tracked-dir1\040/unchanged\040			x
M  tracked-dir1\040/index\040				y
 M tracked-dir1\040/normal\040			z	x
MM tracked-dir1\040/both\040\040\040		z	y
A  tracked-dir1\040/new\040				y
AM tracked-dir1\040/\040changed-new\040		z	y
   tracked-dir1\040/\ntracked-dir2/unchanged	x
M  tracked-dir1\040/\ntracked-dir2/\040index\040	y
 M tracked-dir1\040/\ntracked-dir2/normal	z	x
MM tracked-dir1\040/\ntracked-dir2/\nboth\n\n		z	y
A  tracked-dir1\040/\ntracked-dir2/new			y
AM tracked-dir1\040/\ntracked-dir2/\040changed-new\040 z	y
!! \040ignored-file\040				uf
?? untracked-dir1\040/\040some-file0		uf0
?? untracked-dir1\040/\040some-file1\040	uf1
?? tracked-dir1\040/untracked-file\040		uf
!! tracked-dir1\040/\nignored-dir2/some-file0	uf0
!! tracked-dir1\040/\nignored-dir2/\040some-file1\040\040\040 uf1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
assert_branch_metadata_HT
assert_dotgit_contents
