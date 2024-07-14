. "$(dirname "$0")/../commons.sh" 1>/dev/null

git switch --orphan ooo

printf 'bbb\n' >aaa
git add aaa
if git stash push
then
	# This doesn't work in normal `git stash`
	exit 1
fi
