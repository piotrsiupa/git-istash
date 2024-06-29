. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git add aaa
printf 'ccc\n' >aaa
git stash push

printf 'bbb\n' >aaa
git commit -am 'Changed aaa'

correct_head_hash="$(git rev-parse HEAD)"
git unstash
assert_tracked_files 'aaa'
assert_status ' M aaa'
assert_file_contents aaa 'ccc' 'bbb'
assert_stash_count 0
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
