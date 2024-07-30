. "$(dirname "$0")/../commons.sh" 1>/dev/null

printf 'aaa\n' >aaa
git add aaa
git commit -m 'Added aaa'
printf 'xxx\n' >aaa
git stash push -m 'pre-existing stash 0'
printf 'yyy\n' >aaa
git add aaa
printf 'zzz\n' >aaa
git stash push -m 'pre-existing stash 1'
git reset --hard HEAD~

git switch --orphan ooo

printf 'bbb\n' >aaa
git add aaa
if git stash push
then
	# This doesn't work in normal `git stash`
	exit 1
fi
