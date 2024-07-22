# `git istash` - Improved stash commands for Git

Alternative Git command for handling stashes, without the arbitrary limitations of `git stash`.

It is written entirely in POSIX (Portable Operating System Interface) shell script, making it compatible with basically every operating system (except Windows, but fortunately, Git for Windows can handle POSIX scripts on its own).


## Overview

`git istash` ("improved stash") is an extension for `git stash`, compatible with stash entries created by it.
Use `git istash` commands as a replacement for `git stash` commands with the same names.

### `git istash apply` and `git istash pop`

Both of these commands restore stashed changes to the working directory.
Additionally, `git istash pop` removes the stash entry on success.  
When there are no conflicts, these work the same as `git stash apply --index` and `git stash pop --index`.
In case of conflicts, instead of refusing and demanding to run it without `--index`, they apply index and working directory changes separately and stop to resolve conflicts when needed, similar to `git rebase`.
After the conflicts are resolved, the commands can be resumed with `--continue`.
Alternatively, `--abort` can be used to cancel the operation and return to the repository state before it started.  
Because of the multi-stage conflict resolution, *the index saved to the stash entry will be preserved*.


## Installation

### Every OS except Windows

To install the command for the current user only, run:
```sh
./install.sh
```

To install the command for all users (requires root privileges), run:
```sh
sudo ./install.sh --global
```

Uninstalling is done by rerunning the install command with the added flag `--uninstall`.

You can learn more by running:
```sh
./install.sh --help
```

### Windows

There is a wrapper script that allows running the installer on Windows, although it has fewer options than the normal version.

To install the command for all users (requires administrator access), run:
```bat
windows-install.bat
```

Uninstalling is done by rerunning the same command with the added flag `--uninstall`.

### Testing without Installation

It is possible to run the command without installing it in the system, although it's less convenient:
```sh
cd <path to repository in which to run the command>
<path to this repository>/bin/git-istash
```
(On Windows, you need to use the wrapper script `run-git-bash.bat` in the second line.)


## License

Contents of this repository are distributed under the MIT license. A full copy of it is available in the file [`LICENSE.txt`](LICENSE.txt).


## Planned features

- Creating stash entries when the working directory contains files added with the flag `--intent-to-add`.


## Current limitations

- The script refuses to apply a stash when the working directory contains any changes.
  (For technical reasons, this will be solved only after creating stashes with `--intent-to-add` is implemented.)


## Displaying help / additional information

### Manual

On systems that have `man` installed, after installation, you can view the comprehensive documentation in the usual way, by running the command:
```sh
git help istash
# or
git istash --help
# or
man git-istash
```

It is also possible to display the manual without installation, by running:
```sh
bin/git-istash.sh --help
```

### Brief help text

If `man` is not installed (like in embedded systems) or it doesn't work (as it tends to do on Windows), you can access a rudimentary help text included in the commands.
Each subcommand has its own help text that can be displayed by running:
```sh
git istash [<sub command>] -h
```


## Examples

### Interrupted workflow, without losing index

When you are in the middle of something and you suddenly have a *brilliant idea* for something that should be changed *immediately*, even before the things you're working on currently.
Traditionally, you would make a commit to a temporary branch to store your changes away, and return to your original branch to implement your awesome idea, like this:

```sh
# ... hack hack hack ...
git switch -c my_wip
git commit -a -m "WIP"
git switch original_branch
# Implement the idea
git commit -a -m "Best change ever"
git switch my_wip
git rebase original_branch
git reset --soft HEAD^
git branch -D original_branch
git branch -m original_branch
# ... continue hacking ...
```

The above is complicated and has a lot of steps that can break something if you make a mistake.
Additionally, it doesn't preserve the index.

You can use `git istash` to simplify it *and* keep the index intact:

```sh
# ... hack hack hack ...
git stash
# Implement the idea
git commit -a -m "Best change ever"
git istash pop
# ... continue hacking ...
```

### Applying stash with conflicts both in staged and unstaged changes

So far, you may be thinking:
"Why would I need a custom Git script for that since a normal stash command can do it as well?"  
Let's assume the same scenario as in the example above; however, this time the *brilliant idea* involves editing some of the same lines that are currently changed.

In such situation, normal `git stash` won't let you use the option `--index`, forcing you to discard your changes in index.  
When `git istash` encounters conflicts, it behaves like `git rebase` and stops to allow the user to deal with the problem.
(Actually, it uses `rebase` under the hood.)

```sh
# ... hack hack hack ...
git stash
# Implement the idea
git commit -a -m "Best change ever"
git istash pop
# (git-istash will stop and report that some files have conflicts)
# Fix the conflicts in the index
git add -u
git istash pop --continue
# (git-istash will stop and report that some files have conflicts again)
# Fix the conflicts in unstaged changes
git add -u
git istash pop --continue
# ... continue hacking ...
```

After the whole operation is finished, the stashed index is restored and intact.


## Testing

You can find the tests in the directory [`tests`](/tests).

If you've made changes to the scripts or just want to make sure they're working on your system / version of Git, you can run:
```sh
tests/run.sh
```
or on Windows:
```bat
tests/windows-run.bat
```
*Don't try to directly run individual test files!* They are designed to be run through the main test script and may mess up your files otherwise.

To learn more, read [`tests/README.md`](/tests/README.md) and `tests/run.sh --help`.
