. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
printf 'ccc\n' >ccc
git add aaa bbb ccc
git commit -m 'Added aaa, bbb & ccc'

git switch -d HEAD

git rm aaa
rm bbb
printf 'ddd\n' >ccc
git add ccc
rm ccc
printf 'ddd\n' >ddd
correct_head_hash="$(git rev-parse 'HEAD')"
assert_exit_code 0 git istash push --no-keep-index --message 'mesanmge'
assert_files '
   aaa		aaa
   bbb		bbb
   ccc		ccc
?? ddd		ddd
!! ignored	ignored
'
assert_stash 0 '' 'mesanmge' '
D  aaa
 D bbb			bbb
MD ccc			ddd
'
assert_stash_base 0 'HEAD'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_rebase n

git switch master

assert_exit_code 0 git stash pop --index
assert_files '
D  aaa
 D bbb			bbb
MD ccc			ddd
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
