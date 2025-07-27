# `git istash` - Improved stash command for Git

Alternative Git command for reliably handling stashes, without the arbitrary limitations and corner cases of `git stash`.
([full-list-of-the-changes](#differences-from-the-official-git-stash))

It is written (almost[^1]) entirely in POSIX (Portable Operating System Interface) shell script, making it compatible with basically every operating system (except Windows, but fortunately, Git for Windows can handle POSIX scripts on its own).

[^1]: The scripts use the program `getopt` for parsing options and the `-r` flag for `xargs`, both of which are not part of the standard but are widely supported.


## Overview

`git istash` ("incredible stash") is an extension for `git stash`, compatible with stash entries created by it.
Use `git istash` subcommands as a replacement for `git stash` subcommands with the same names.

### `git istash create`, `git istash snatch`, `git istash save` and `git istash push`

These subcommands create a new stash, compatible with the standard Git stash format (except for some corner cases and exceptions in the vanilla command).
The `git istash push` behaves almost the same as the standard `git stash push` but it can handle some additional situation (like creating a stash from an orphan branch),
it has a few additional options (e.g. for stashing only staged / unstaged files),
and it's generally more reliable and predictable because it has no corner cases and / or exceptions. \
The three other subcommands differ from the `push` in whether they store the created stash in the stash ref and whether they revert the stashed changes from the working directory.
`git istash create` works similarly to `git stash create` except it takes options.
`git istash snatch` and `git istash save` don't have vanilla equivalents. (`git istash save` differs a lot from `git stash save`.)

| Subcommand | Keeps the changes in WD | Stores the created stash |
|------------|-------------------------|--------------------------|
|   `create` | YES                     | NO                       |
|   `snatch` | NO (can keep index)     | NO                       |
|     `save` | YES                     | YES                      |
|     `push` | NO (can keep index)     | YES                      |

### `git istash apply` and `git istash pop`

Both of these subcommands restore stashed changes to the working directory.
Additionally, `git istash pop` removes the stash entry on success.  
When there are no conflicts, these work the same as `git stash apply --index` and `git stash pop --index`.
In case of conflicts, instead of refusing and demanding to run it without `--index`, they apply index and working directory changes separately and stop to resolve conflicts when needed, similar to `git rebase`.
After the conflicts are resolved, the subcommands can be resumed with `--continue`.
Alternatively, `--abort` can be used to cancel the operation and return to the repository state before it started.  
Because of the multi-stage conflict resolution, *the index saved to the stash entry will be preserved*.

| Subcommand | Removes the stash from the stash ref |
|------------|--------------------------------------|
|    `apply` | NO                                   |
|      `pop` | YES (if it succeeded)                |



## Installation

This command requires Git in version `2.42.0` or higher to be present.
Otherwise, the installation will succeed but the command will refuse to run until the required version of Git is provided.
(Except for Windows, which needs Git to run the installer, because it uses the shell implementation provided by git.)

### Every OS except Windows

To install `git istash` ("ingenious stash") for the current user only, run:
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



## Differences from the official `git stash`

There are a few deliberate and planned divergences from the ways that the standard Git stash works.
Most of the changes here, however, are bugs that were found during tests to be present in the standard implementation.

### Main changes
- There is no option `--index` for `apply` and `pop`.
  Instead, those subcommands always behave as if that option were present.
- The stash is being applied in stages (index, then tracked files and then untracked files), the same way as rebasing multiple commits applies these commits one by one in order.
  This allows solving conflicts without sacrificing the information about the index.
  (In case of a conflict, the process is stopped and it can be resumed after the problem is solved, just like `rebase` does.)

### Fixed bugs
- `push --keep-index` returns a non-0 exit code when there is no tracked files in the repository.
  (It should be fixed in the standard command in Git `v2.46.1`.)
- Untracked files are added to a new stash even with `--no-include-untracked` when they names are the same as names of files removed in index.
  (According to the Git test suite this is an expected behavior.)
- `push` loses the information about deletion of a file if it's a new file added to index.
- `push` returns 0 when stash has failed to be created (when there are no changes).
- Option `--patch` doesn't allow stash with no selected changes even when there are changes in index.
- Option `--patch` with `--keep-index` doesn't keep the index.
- `push` with `--path` fails if a new file was added and then modified.
- Pathspecs are unable to find untracked files when the option `--keep-index` is specified.
- `push` with a pathspec creates a stash even when it fails to match a file and returns a non-0 exit code.
- `--patch` doesn't exit with an error when `e` was used to take only some of consecutive changed lines.
  (Although, the result isn't ideal because the stashed changes aren't remove from the working directory in this case.)

### Other things different in standard `stash` (that may or may not be considered bugs)
- Options can now follow non-option arguments (like they are allowed to in POSIX utilities).
- Option `--no-include-untracked` doesn't override `--all` anymore.
  (Instead, ignored files are included if both options are specified.)
- A new option `--leave-staged` skips staged files when creating a stash and leaves them untouched.
- A new option `--staged` skips unstaged files when creating a stash and leaves them untouched.
- Option `--patch` now works with untracked files.
- Options `--patch` and `--pathspec-from-file` are allowed together now.
- Files in index are affected by the pathspec now.
- Stash can be created on an orphan branch now.
- There is an option `--allow-empty` now, that allows creation of stash when there are no changes.
- `git istash create` supports all the options that `git istash push` does.
- There are two additional subcommands (`snatch` and `save`) that aren't present in the vanilla stash.



## Known problems and limitations

- The command refuses to apply a stash when the working directory contains any changes.
  (Planned to be implemented soon.)
- Changes are not removed from working directory when `--patch` with `e` was used to stash only some of consecutive changed lines.
  (It will be fixed if I can figure out a way to do it in a consistent way.)
- Not all subcommands from the vanilla command are present (like `git stash show`, `git stash list`...).
  (However, most of the vanilla subcommands are fully compatible with stashes created by this commands.)
- Because this command is written entirely in the shell script, it's slower than standard commands (especially on Windows).
  The advantage of it being a script is that it can run on every system with very little additional development cost.
  (A few seconds to make a stash isn't that big deal, though, so it probably won't be improved any time soon, especially that this would likely require rewriting the command to another language.)



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
git istash [<subcommand>] -h
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

You can use `git istash` ("immaculate stash") to simplify it *and* keep the index intact:

```sh
# ... hack hack hack ...
git istash
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
When `git istash` ("impressive stash") encounters conflicts, it behaves like `git rebase` and stops to allow the user to deal with the problem.
(Actually, it uses `rebase` under the hood.)

```sh
# ... hack hack hack ...
git istash
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


## Stashing away untracked files

You've created a few new files yet to be added to the repository but you've realized that you will need them a little later and they are getting in the way of what you're doing right now.

You would like to move them somewhere where they won't bother you for now, but keep them safe.

```sh
# ... hack hack hack ...
$ git istash push --leave-staged --staged --include-untracked -m 'some new files, for safe keeping'
# (or just "git istash push -lSu")
# ... continue hacking until the files are needed ...
$ git istash pop
# ... hacking intensifies ...
```



## Testing

You can find the tests for `git-istash` ("infallible stash") and its subcommands in the directory [`tests`](/tests).

If you've made changes to the scripts or just want to make sure they're working on your system / version of Git, you can run:
```sh
tests/run.sh
```
or on Windows:
```bat
tests/windows-run.bat
```
*Don't try to directly run individual test files!*
They are designed to be run through the main test script and may mess up your files otherwise.
(There are safeguards but still don't try.)

To learn more, read [`tests/README.md`](/tests/README.md) and `tests/run.sh --help`.
