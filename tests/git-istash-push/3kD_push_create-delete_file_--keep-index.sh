exit 0  #TODO the test is disabled because `git stash` has a bug(?) and doesn't create the stash correctly in this case. (`git stash` is planned to not be used internally in `git istash` in the future.)

. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

git switch -d HEAD

printf 'bbb\n' >bbb
git add bbb
rm bbb
printf 'ddd\n' >ddd
correct_head_hash="$(git rev-parse 'HEAD')"
assert_exit_code 0 git istash push --keep-index --message 'mesanmge'
assert_files '
   aaa		aaa
A  bbb			bbb
?? ddd		ddd
!! ignored	ignored
'
assert_stash 0 '' 'mesanmge' '
   aaa
AD bbb			bbb
'
assert_stash_base 0 'HEAD'
assert_stash_count 1
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'HEAD'
assert_rebase n

git reset --hard
git switch master

assert_exit_code 0 git stash pop --index
assert_files '
   aaa		aaa
AD bbb			bbb
?? ddd		ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_name 'master'
assert_rebase n
