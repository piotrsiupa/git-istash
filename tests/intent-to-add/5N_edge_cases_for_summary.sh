. "$(dirname "$0")/../commons.sh" 1>/dev/null

# Tests for all the different cases for the algorithm deciding what status should be shown in the post-apply summary.
# (See the Karnaugh maps in the log of the commit 50abf565859942c5e19dc2dbea8dd583ddd4bf76.)

non_essential_test

PARAMETRIZE_HEAD_TYPE 'BRANCH' 'DETACH' 'ORPHAN'
PARAMETRIZE_APPLY_OPERATION
PARAMETRIZE_CONTINUE
PARAMETRIZE_COLOR
PARAMETRIZE_QUIET
PARAMETRIZE_SUMMARY
PARAMETRIZE_HINT 'istashConflicts'

__end_of_initialization__

prepare_repository
rm ignored0 ignored1

__test_section__ 'Create stash'
printf 'aaa0x\n' >n2x
printf 'aaa01\n' >n2u
printf 'aaa02\n' >n2t
printf 'aaa03\n' >n2i
printf 'aaa04\n' >n2id
git add -N n2t
git add n2i n2id
printf 'aaaxx\n' >x2x
printf 'aaaxx_\n' >x2x_
printf 'aaax1\n' >x2u
printf 'aaax2\n' >x2t
printf 'aaax3\n' >x2i
printf 'aaax4\n' >x2id
git add -N x2t
git add x2i x2id
printf 'aaa1x\n' >u2x
printf 'aaa11\n' >u2u
printf 'aaa11_\n' >u2u_
printf 'aaa12\n' >u2t
printf 'aaa13\n' >u2i
printf 'aaa14\n' >u2id
git add -N u2t
git add u2i u2id
printf 'aaa2x\n' >t2x
printf 'aaa21\n' >t2u
printf 'aaa22\n' >t2t
printf 'aaa22_\n' >t2t_
printf 'aaa23\n' >t2i
printf 'aaa23_\n' >t2i_
printf 'aaa24\n' >t2id
git add -N t2t t2t_
git add t2i t2i_ t2id
printf 'aaa3x\n' >i2x
printf 'aaa31\n' >i2u
printf 'aaa32\n' >i2t
printf 'aaa33\n' >i2i
printf 'aaa33_\n' >i2i_
printf 'aaa34\n' >i2id
printf 'aaa34_\n' >i2id_
git add -N i2t
git add i2i i2i_ i2id i2id_
printf 'aaa4x\n' >id2x
printf 'aaa41\n' >id2u
printf 'aaa42\n' >id2t
printf 'aaa43\n' >id2i
printf 'aaa43_\n' >id2i_
printf 'aaa44\n' >id2id
printf 'aaa44_\n' >id2id_
git add -N id2t
git add id2i id2i_ id2id id2id_
git istash push -a

SWITCH_HEAD_TYPE
printf 'bbbx0\n' >x2n
printf 'bbbxx\n' >x2x
printf 'bbbxx_\n' >x2x_
printf 'bbbx1\n' >x2u
printf 'bbbx2\n' >x2t
printf 'bbbx3\n' >x2i
printf 'bbbx4\n' >x2id
printf 'bbb10\n' >u2n
printf 'bbb1x\n' >u2x
printf 'bbb11\n' >u2u
printf 'bbb11_\n' >u2u_
printf 'bbb12\n' >u2t
printf 'bbb13\n' >u2i
printf 'bbb14\n' >u2id
printf 'bbb20\n' >t2n
printf 'bbb2x\n' >t2x
printf 'bbb21\n' >t2u
printf 'bbb22\n' >t2t
printf 'bbb22_\n' >t2t_
printf 'bbb23\n' >t2i
printf 'bbb23_\n' >t2i_
printf 'bbb24\n' >t2id
git add -N t2n t2x t2u t2t t2t_ t2i t2i_ t2id
printf 'bbb30\n' >i2n
printf 'bbb3x\n' >i2x
printf 'bbb31\n' >i2u
printf 'bbb32\n' >i2t
printf 'bbb33\n' >i2i
printf 'bbb33_\n' >i2i_
printf 'bbb34\n' >i2id
printf 'bbb34_\n' >i2id_
git add i2n i2x i2u i2t i2i i2i_ i2id i2id_
printf 'bbb40\n' >id2n
printf 'bbb4x\n' >id2x
printf 'bbb41\n' >id2u
printf 'bbb42\n' >id2t
printf 'bbb43\n' >id2i
printf 'bbb43_\n' >id2i_
printf 'bbb44\n' >id2id
printf 'bbb44_\n' >id2id_
git add id2n id2x id2u id2t id2i id2i_ id2id id2id_
rm id2n id2u id2x id2t id2i id2i_ id2id id2id_

__test_section__ 'Dirty the working directory & create conflict'

__test_section__ "$CAP_APPLY_OPERATION stash"
correct_head_sha="$(get_head_sha_HT)"
printf 'x2*\n' >.git/info/exclude
#shellcheck disable=SC2086
assert_exit_code 2 git $ADVICE_FLAGS istash "$APPLY_OPERATION" $COLOR_FLAGS $QUIET_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 0 '
AA i2i
AA i2i_
AA i2id
AA i2id_
AA id2i
AA id2i_
AA id2id
AA id2id_
'
assert_files_HT '
A  n2i		aaa03
A  n2id		aaa04
!! x2n		bbbx0
!! x2x		bbbxx
!! x2x_		bbbxx_
!! x2u		bbbx1
!! x2t		bbbx2
A  x2i		aaax3
A  x2id		aaax4
A  u2i		aaa13
A  u2id		aaa14
A  t2i		aaa23
A  t2i_		aaa23_
A  t2id		aaa24
   i2n		bbb30
   i2x		bbb3x
   i2u		bbb31
   i2t		bbb32
AA i2i		bbb33|aaa33
AA i2i_		bbb33_|aaa33_
AA i2id		bbb34|aaa34
AA i2id_	bbb34_|aaa34_
   id2n		bbb40
   id2x		bbb4x
   id2u		bbb41
   id2t		bbb42
AA id2i		bbb43|aaa43
AA id2i_	bbb43_|aaa43_
AA id2id	bbb44|aaa44
AA id2id_	bbb44_|aaa44_
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (0)"
printf 'ccc03\n' >n2i__
printf 'ccc04\n' >n2id__
git add n2i__ n2id__
git rm --force i2n i2x i2u i2t
printf 'aaa33\n' >i2i
printf 'bbb33_\n' >i2i_
printf 'aaa34\n' >i2id
printf 'bbb34_\n' >i2id_
git add i2i i2i_ i2id i2id_
git rm --force id2n id2x id2u id2t
printf 'aaa43\n' >id2i
printf 'bbb43_\n' >id2i_
printf 'aaa44\n' >id2id
printf 'bbb44_\n' >id2id_
git add id2i id2i_ id2id id2id_
#shellcheck disable=SC2086
assert_exit_code 2 git $ADVICE_FLAGS istash "$APPLY_OPERATION" $COLOR_FLAGS "$CONTINUE_FLAG" $QUIET_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 1 '
AA t2i
AA t2i_
AA t2id
UD id2i
UD id2id
'
assert_files_HT '
   n2i		aaa03
   n2i__	ccc03
   n2id		aaa04
   n2id__	ccc04
!! x2n		bbbx0
!! x2x		bbbxx
!! x2x_		bbbxx_
!! x2u		bbbx1
!! x2t		bbbx2
   x2i		aaax3
   x2id		aaax4
   u2i		aaa13
   u2id		aaa14
A  t2n		bbb20
A  t2x		bbb2x
A  t2u		bbb21
A  t2t		bbb22
A  t2t_		bbb22_
AA t2i		aaa23|bbb23
AA t2i_		aaa23_|bbb23_
AA t2id		aaa24|bbb24
   i2i		aaa33
   i2i_		bbb33_
   i2id		aaa34
   i2id_	bbb34_
UD id2i		aaa43
D  id2i_
UD id2id	aaa44
D  id2id_
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (1)"
printf 'aaa23\n' >t2i
printf 'bbb23_\n' >t2i_
printf 'aaa24\n' >t2id
git add t2i t2i_ t2id
printf 'aaa43\n' >id2i
git restore --staged id2i_
git restore id2i_
printf 'aaa44\n' >id2id
git add id2i id2id
#shellcheck disable=SC2086
assert_exit_code 2 git $ADVICE_FLAGS istash "$APPLY_OPERATION" $COLOR_FLAGS "$CONTINUE_FLAG" $QUIET_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 2 '
AA t2t
AA t2t_
'
assert_files_HT '
A  n2t		aaa02
   n2i		aaa03
   n2i__	ccc03
   n2id		aaa04
   n2id__	ccc04
!! x2n		bbbx0
!! x2x		bbbxx
!! x2x_		bbbxx_
!! x2u		bbbx1
A  x2t		aaax2
   x2i		aaax3
   x2id		aaax4
A  u2t		aaa12
   u2i		aaa13
   u2id		aaa14
   t2n		bbb20
   t2x		bbb2x
   t2u		bbb21
AA t2t		bbb22|aaa22
AA t2t_		bbb22_|aaa22_
   t2i		aaa23
   t2i_		bbb23_
   t2id		aaa24
A  i2t		aaa32
   i2i		aaa33
   i2i_		bbb33_
   i2id		aaa34
   i2id_	bbb34_
A  id2t		aaa42
   id2i		aaa43
   id2i_	bbb43_
   id2id	aaa44
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (2)"
printf 'ccc02\n' >n2t__
git add n2t__
git rm --force n2id n2id__ x2id u2id t2n t2x t2u
printf 'aaa22\n' >t2t
printf 'bbb22_\n' >t2t_
git add t2t t2t_
git rm --force t2id i2id i2id_ id2id
#shellcheck disable=SC2086
assert_exit_code 2 git $ADVICE_FLAGS istash "$APPLY_OPERATION" $COLOR_FLAGS "$CONTINUE_FLAG" $QUIET_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 3 '
AA u2t
AA u2i
'
assert_files_HT '
   n2t		aaa02
   n2t__	ccc02
   n2i		aaa03
   n2i__	ccc03
!! x2n		bbbx0
!! x2x		bbbxx
!! x2x_		bbbxx_
!! x2u		bbbx1
   x2t		aaax2
   x2i		aaax3
A  u2n		bbb10
A  u2x		bbb1x
A  u2u		bbb11
A  u2u_		bbb11_
AA u2t		aaa12|bbb12
AA u2i		aaa13|bbb13
A  u2id		bbb14
   t2t		aaa22
   t2t_		bbb22_
   t2i		aaa23
   t2i_		bbb23_
   i2t		aaa32
   i2i		aaa33
   i2i_		bbb33_
   id2t		aaa42
   id2i		aaa43
   id2i_	bbb43_
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (3)"
printf 'aaa12\n' >u2t
printf 'aaa13\n' >u2i
git add u2t u2i
#shellcheck disable=SC2086
assert_exit_code 2 git $ADVICE_FLAGS istash "$APPLY_OPERATION" $COLOR_FLAGS "$CONTINUE_FLAG" $QUIET_FLAGS
assert_outputs__apply__conflict "$APPLY_OPERATION" 4 '
AA u2x
AA u2u
AA u2u_
'
assert_files_HT '
A  n2x		aaa0x
A  n2u		aaa01
   n2t		aaa02
   n2t__	ccc02
   n2i		aaa03
   n2i__	ccc03
!! x2n		bbbx0
A  x2x		aaaxx
A  x2x_		aaaxx_
A  x2u		aaax1
   x2t		aaax2
   x2i		aaax3
   u2n		bbb10
AA u2x		bbb1x|aaa1x
AA u2u		bbb11|aaa11
AA u2u_		bbb11_|aaa11_
   u2t		aaa12
   u2i		aaa13
   u2id		bbb14
A  t2x		aaa2x
A  t2u		aaa21
   t2t		aaa22
   t2t_		bbb22_
   t2i		aaa23
   t2i_		bbb23_
A  i2x		aaa3x
A  i2u		aaa31
   i2t		aaa32
   i2i		aaa33
   i2i_		bbb33_
A  id2x		aaa4x
A  id2u		aaa41
   id2t		aaa42
   id2i		aaa43
   id2i_	bbb43_
'
assert_stash_count 1
assert_branch_count_HT 1
assert_data_files "$APPLY_OPERATION"
assert_rebase y
assert_dotgit_contents_for "$APPLY_OPERATION"

__test_section__ "Continue $APPLY_OPERATION stash (4)"
printf '*2x*\n' >.git/info/exclude
printf 'ccc0x\n' >n2x__
printf 'ccc01\n' >n2u__
git add --force n2x__ n2u__
rm x2n
git rm u2n
printf 'bbbxx_\n' >x2x_
printf 'aaa1x\n' >u2x
printf 'aaa11\n' >u2u
printf 'bbb11_\n' >u2u_
git rm u2id
printf 'aaa21\n' >t2u
git add x2x_ u2x u2u u2u_ t2u
stash_sha="$(git rev-parse stash)"
#shellcheck disable=SC2086
assert_exit_code 0 git $ADVICE_FLAGS istash "$APPLY_OPERATION" $COLOR_FLAGS $SUMMARY_FLAGS "$CONTINUE_FLAG" $QUIET_FLAGS
assert_outputs__apply__success "$APPLY_OPERATION" '
!A n2x
!A n2x__
?A n2u
?A n2u__
 A n2t
 A n2t__
A  n2i
A  n2i__
AD n2id
AD n2id__
!M x2x
!M x2x_
?A x2u
 A x2t
A  x2i
AD x2id
?D u2n
!! u2x
?M u2u
 A u2t
A  u2i
AD u2id
 D t2n
 D t2x
!! t2x
 D t2u
?A t2u
 M t2t
A  t2i
AM t2i_
AD t2id
D  i2n
D  i2x
!! i2x
D  i2u
?A i2u
DA i2t
M  i2i
MD i2id
 D i2id_
D  id2n
D  id2x
!A id2x
D  id2u
?A id2u
DA id2t
MA id2i
 A id2i_
M  id2id
' 0 "$stash_sha"
assert_files_HT '
!! n2x          aaa0x
!! n2x__        ccc0x
?? n2u		aaa01
?? n2u__	ccc01
 A n2t		aaa02
 A n2t__	ccc02
A  n2i		aaa03
A  n2i__	ccc03
AD n2id		aaa04
AD n2id__	ccc04
!! x2x		aaaxx
!! x2x_		bbbxx_
?? x2u		aaax1
 A x2t		aaax2
A  x2i		aaax3
AD x2id		aaax4
!! u2x		aaa1x
?? u2u		aaa11
?? u2u_		bbb11_
 A u2t		aaa12
A  u2i		aaa13
AD u2id		aaa14
!! t2x		aaa2x
?? t2u		aaa21
 A t2t		aaa22
 A t2t_		bbb22_
A  t2i		aaa23
AM t2i_		bbb23_	aaa23_
AD t2id		aaa24
!! i2x		aaa3x
?? i2u		aaa31
 A i2t		aaa32
A  i2i		aaa33
A  i2i_		bbb33_
AD i2id		aaa34
AD i2id_	bbb34_
!! id2x		aaa4x
?? id2u		aaa41
 A id2t		aaa42
A  id2i		aaa43
A  id2i_	bbb43_
AD id2id	aaa44
AD id2id_	bbb44_
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
