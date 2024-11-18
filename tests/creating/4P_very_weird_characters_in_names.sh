# BE VERY CAREFULL EDITING THIS FILE!
# There is a good chance your editor will mangle the characters used here.

. "$(dirname "$0")/../commons.sh" 1>/dev/null

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH'
PARAMETRIZE_ALL 'YES'
PARAMETRIZE_UNTRACKED 'DEFAULT' 'YES'
PARAMETRIZE_KEEP_INDEX

# We don't need thos in this test.
rm ignored0 ignored1

# Some tracked files to make it harder on the algorithms creating the commit for ignored ones.
__test_section__ 'Prepare repository'
printf 'x\n' >'unchanged'
printf 'x\n' >'index'
printf 'x\n' >'normal'
printf 'x\n' >'bo	=���{}\*?#@!|:<>()^&th'
mkdir 'tra	=���{}\*?#@!|:<>()^&cked-dir1'
printf 'x\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/unchanged'
printf 'x\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/index'
printf 'x\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/normal'
printf 'x\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/bo	=���{}\*?#@!|:<>()^&th'
mkdir 'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2'
printf 'x\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/unchanged'
printf 'x\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/index'
printf 'x\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/normal'
printf 'x\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/bo	=���{}\*?#@!|:<>()^&th'
git add .
git commit -m 'Added some files'

correct_head_hash="$(get_head_hash)"
SWITCH_HEAD_TYPE

__test_section__ 'Create stash'
printf 'y\n' >'index'
printf 'y\n' >'bo	=���{}\*?#@!|:<>()^&th'
printf 'y\n' >'new'
printf 'y\n' >'changed-new'
printf 'y\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/index'
printf 'y\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/bo	=���{}\*?#@!|:<>()^&th'
printf 'y\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/new'
printf 'y\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/changed-new'
printf 'y\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/index'
printf 'y\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/bo	=���{}\*?#@!|:<>()^&th'
printf 'y\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/new'
printf 'y\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/changed-new'
git add .
printf 'z\n' >'normal'
printf 'z\n' >'bo	=���{}\*?#@!|:<>()^&th'
printf 'z\n' >'changed-new'
printf 'z\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/normal'
printf 'z\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/bo	=���{}\*?#@!|:<>()^&th'
printf 'z\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/changed-new'
printf 'z\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/normal'
printf 'z\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/bo	=���{}\*?#@!|:<>()^&th'
printf 'z\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/tracked-dir2/changed-new'
# And now the ignored files.
printf 'uf\n' >'ignored-file'
mkdir 'untracked-dir1'
printf 'uf0\n' >'untracked-dir1/some-file0'
printf 'uf1\n' >'untracked-dir1/some-file1'
printf 'uf\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/untracked-file'
mkdir 'tra	=���{}\*?#@!|:<>()^&cked-dir1/ignored-di	=���{}\*?#@!|:<>()^&r2'
printf 'uf0\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/ignored-di	=���{}\*?#@!|:<>()^&r2/some	=���{}\*?#@!|:<>()^&file0'
printf 'uf1\n' >'tra	=���{}\*?#@!|:<>()^&cked-dir1/ignored-di	=���{}\*?#@!|:<>()^&r2/some-file1'
printf '%s\n' '*ignored*' >.git/info/exclude
assert_exit_code 0 git istash push $KEEP_INDEX_FLAGS $ALL_FLAGS $UNTRACKED_FLAGS
if ! IS_KEEP_INDEX_ON
then
	assert_files_H '
	   unchanged					x
	   index					x
	   normal					x
	   bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th x
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/unchanged			x
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/index				x
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/normal				x
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th				x
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/unchanged		x
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/index		x
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/normal		x
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th		x
	'
else
	assert_files_H '
	   unchanged					x
	M  index						y
	   normal					x
	M  bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th y
	A  new							y
	A  changed-new						y
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/unchanged x
	M  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/index y
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/normal x
	M  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th y
	A  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/new y
	A  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/changed-new y
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/unchanged x
	M  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/index y
	   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/normal x
	M  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th y
	A  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/new y
	A  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/changed-new y
	'
fi
assert_stash_H 0 '' '
   unchanged					x
M  index						y
 M normal					z	x
MM bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th z y
A  new							y
AM changed-new					z	y
   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/unchanged x
M  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/index y
 M tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/normal z	x
MM tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th z y
A  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/new y
AM tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/changed-new z y
   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/unchanged x
M  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/index y
 M tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/normal z x
MM tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th z y
A  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/new y
AM tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/changed-new z y
!! ignored-file					uf
?? untracked-dir1/some-file0			uf0
?? untracked-dir1/some-file1			uf1
?? tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/untracked-file			uf
!! tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/ignored-di\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&r2/some\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&file0 uf0
!! tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/ignored-di\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&r2/some-file1 uf1
'
assert_stash_base_H 0 'HEAD'
assert_stash_count 1
assert_log_length_H 2
assert_branch_count 1
assert_head_hash_H "$correct_head_hash"
assert_head_name_H
assert_rebase n

git reset --hard
RESTORE_HEAD_TYPE

__test_section__ 'Pop stash'
assert_exit_code 0 git stash pop --index
assert_files '
   unchanged					x
M  index						y
 M normal					z	x
MM bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th z y
A  new							y
AM changed-new					z	y
   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/unchanged x
M  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/index y
 M tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/normal z x
MM tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th z y
A  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/new y
AM tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/changed-new z y
   tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/unchanged x
M  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/index y
 M tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/normal z x
MM tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/bo\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&th z y
A  tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/new y
AM tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/tracked-dir2/changed-new	z y
!! ignored-file					uf
?? untracked-dir1/some-file0			uf0
?? untracked-dir1/some-file1			uf1
?? tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/untracked-file uf
!! tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/ignored-di\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&r2/some\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&file0 uf0
!! tra\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&cked-dir1/ignored-di\001\002\003\004\005\006\007\010\t=\377\376\177\200{}\\*?#@!|:<>()^&r2/some-file1 uf1
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_rebase n
