This directory contain tests and related scripts.
The most notable files are `run.sh` and `shellcheck.sh`.


# `run.sh`

The script that runs all the tests placed in this directory.
Executing it without parameters will run all the tests.
(For more information, run `run.sh --help`.)


# `shellcheck.sh`

A script that checks all the scripts in the projects (including the tests), using `shellcheck`.
(For more information, run `shellcheck.sh --help`.)


# `commons.sh`

A helper file with utility functions for implementing tests.
This script is **not** intended to be used outside of tests.


# Tests

Each test is saved in a `*.sh` file, in a sub-directory (named the same after the tested command).
The file patch relative to the directory `tests` but without the extension is the name of the test.

Tests are scripts that return an exit code `0` if the tests passed and non-`0` otherwise.
To run a test, use the script `run.sh` which will create and initialize a new Git repository in which the test can be safely run.
*Running a test without `run.sh` may mess up files in the Git repository or in the current directory.*

## Naming convention

`run.sh` don't care about tests names beside the extension, but they are also some conventions that serve to simplify sorting, filtering and handling the tests files in general.

Also, note that tests should not use any funny characters that would mess up shell commands and have all spaces replaced by `_`.
(`_` are converted back to ` ` when pretty printing the tests names, and `/` are converted to ` -> `.)

### Prefix
Each test has 2-character or 3-character prefix followed by a `_`.
Generally these prefixes work as follows:
- The first character is a digit representing the general category of the test.
  - For `git-istash` the categories are:
    - `1` - Errors for invalid arguments.
  - For `git-istash-apply` & `git-istash-pop` the categories are:
    - `0` - Sanity tests that don't use git commands from this repository.
    - `1` - Popping/Applying without conflicts.
    - `2` - Popping/Applying with conflicts that need to be manually solved.
    - `3` - Popping/Applying with "conflicts" that can be automatically resolved by Git merge algorithms.
    - `4` - Popping/Applying with conflicts that is aborted before they are resolved.
    - `5` - Different ways of specifying which stash to use.
    - `6` - Specifying a stash that doesn't exist.
    - `7` - Trying to istash when the repository is not in a state that allows that (e.g. an istash is already in progress).
    - `8` - Handling various errors.
    - `9` - Popping/Applying with sub-directories in the repository and when the working directory is not the repository's root.
  - For `git-istash-push` the categories are:
    - `0` - Sanity tests that don't use git commands from this repository.
    - `1` - pushing without additional options.
    - `2` - pushing with `--no-keep-index`.
    - `3` - pushing with `--keep-index`.
- The second character is a lowercase letter that with tandem with the digit acts as an ID of the test in the current directory.
- The third character (which is skipped for the tests in the directory `git-istash`) is an uppercase letter and it describes the state of Git `HEAD` on which the test is performed:
  - `B` - `HEAD` points to a normal Git branch.
  - `D` - `HEAD` is detached (it only points to a commit hash).
  - `O` - `HEAD` doesn't exist because the operation is performed on a freshly created orphan branch.
