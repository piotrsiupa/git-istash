. "$(dirname "$0")/../commons.sh" 1>/dev/null

mkdir xxx yyy
printf 'bbb0\n' >aaa
printf 'bbb1\n' >xxx/aaa
printf 'bbb2\n' >yyy/aaa
git add aaa xxx/aaa yyy/aaa
printf 'ccc0\n' >aaa
printf 'ccc1\n' >xxx/aaa
printf 'ccc2\n' >yyy/aaa
printf 'zzz0\n' >zzz
printf 'zzz1\n' >xxx/zzz
printf 'zzz2\n' >yyy/zzz

git switch --orphan ooo

cd xxx
if git stash push -u --message 'some name'
then
	# This doesn't work in normal `git stash`
	exit 1
fi
cd ..
