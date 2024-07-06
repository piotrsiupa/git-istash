. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'

printf 'bbb\n' >aaa
git stash push

git switch --orphan ooo

printf '#!/usr/bin/env sh\nexit 1\n' >.git/hooks/pre-rebase
chmod +x .git/hooks/pre-rebase
assert_exit_code 1 git istash-pop
assert_status ''
assert_stash_count 1
assert_branch_count 1
assert_head_name '~ooo'
assert_data_files 'none'
assert_rebase n
