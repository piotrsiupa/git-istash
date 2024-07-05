. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

git switch -d HEAD

assert_failure capture_outputs git istash-apply
assert_conflict_message git istash-apply
assert_tracked_files 'aaa'
assert_status 'UU aaa'
assert_stash_count 1
assert_branch_count 1
assert_data_files 'apply'

printf 'eee\n' >aaa
git add aaa
rm -rf '.git/rebase-apply' '.git/rebase-merge'
assert_failure git istash-apply --continue
assert_tracked_files 'aaa'
assert_status 'M  aaa'
assert_file_contents aaa 'eee' 'eee'
assert_stash_count 1
assert_branch_count 1
assert_head_name 'HEAD'
assert_data_files 'apply'
