. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
printf 'bbb\n' >bbb
printf 'ccc\n' >ccc
git add aaa bbb ccc
git commit -m 'Added aaa, bbb & ccc'

git rm aaa
rm bbb
printf 'ddd\n' >ccc
git add ccc
rm ccc
git stash push

correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 0 git istash pop
assert_files '
D  aaa
 D bbb			bbb
MD ccc			ddd
!! ignored	ignored
'
assert_stash_count 0
assert_log_length 2
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
