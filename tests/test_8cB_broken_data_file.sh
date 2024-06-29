. "$(dirname "$0")/commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

correct_head_hash="$(git rev-parse HEAD)"
assert_failure capture_outputs git unstash
assert_conflict_message git unstash
assert_tracked_files 'aaa'
assert_status 'UU aaa'
assert_stash_count 1
assert_branch_count 1

correct_head_hash2="$(git rev-parse HEAD)"
printf 'eee\n' >aaa
git add aaa
cp ./.git/unstash ./.git/unstash~
printf '' >./.git/unstash
assert_failure git unstash --continue
assert_tracked_files 'aaa'
assert_status 'M  aaa'
assert_stash_count 1
assert_branch_count 1
assert_head_hash "$correct_head_hash2"

cp ./.git/unstash~ ./.git/unstash
assert_success git unstash --continue
assert_tracked_files 'aaa'
assert_status ' M aaa'
assert_file_contents aaa 'eee' 'ddd'
assert_stash_count 0
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
