. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

printf 'ddd\n' >aaa
git commit -am 'Changed aaa'

printf '#!/usr/bin/env sh\nexit 1\n' >.git/hooks/pre-rebase
chmod +x .git/hooks/pre-rebase
correct_head_hash="$(git rev-parse HEAD)"
assert_exit_code 1 git istash apply
assert_files '
   aaa		ddd
!! ignored	ignored
'
assert_stash_count 1
assert_log_length 3
assert_branch_count 1
assert_head_hash "$correct_head_hash"
assert_head_name 'master'
assert_data_files 'none'
assert_rebase n
