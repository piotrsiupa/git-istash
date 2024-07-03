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

correct_head_hash="$(git rev-parse HEAD)"
assert_failure git istash-apply
assert_tracked_files 'aaa'
assert_status 'UU aaa'
assert_stash_count 1
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_data_files 'apply'
