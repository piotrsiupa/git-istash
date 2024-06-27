This directory contain tests and related scripts.
The most notable files are `run.sh` and `shellcheck.sh`.


# `run.sh`

The script that runs all the tests placed in this directory.
Executing it without parameters will run all the tests.
(For more information, run `run.sh --help`.)


# `shellcheck.sh`

A script that checks all the scripts in the projects (including the tests), using `shellcheck`.
(For more information, run `shellcheck.sh --help`.)


# `utils.sh`

A helper file with utility functions for implementing tests.
This script is not intended to use outside of tests.


# Tests

Each test is saved in a `*.sh` file, which name starts with `test_`.
The rest of the file name is treated as the name of the test.

Tests are scripts that return an exit code `0` if the tests passed and non-`0` otherwise.
To run a test, use the script `run.sh` which will create and initialize a new Git repository in which the test can be safely run.
*Running a test without `run.sh` may mess up files in the Git repository or in the current directory.*

## Naming convention

`run.sh` don't care about tests names beside the rules stated above, but they are also some conventions that serve to simplify sorting, filtering and handling the tests files in general.

Also, note that tests should not use any funny characters that would mess up shell commands and have all spaces replaced by `_`.
(`_` are converted back to ` ` when pretty printing the tests names.)

### Prefix
Each test has 3-character prefix followed by a `_`.
- The digit at the first position is the general category of the test:  
  `0` - Sanity tests that don't use git commands from this repository.  
  `1` - Unstashing without conflicts.  
  `2` - Unstashing with conflicts that need to be manually solved.  
  `3` - Unstashing with "conflicts" that can be automatically resolved by Git merge algorithms.  
  `4` - Unstashing with conflicts that is aborted before they are resolved.  
  `5` - Different ways of specifying which stash to use.  
  `6` - Specifying a stash that doesn't exist.  
  `7` - Trying to unstash when the repository is not in a state that allows that (e.g. an unstash is already in progress).  
  `8` - Handling miscellaneous errors.  
  `9` - Unstashing with sub-directories in the repository and when the working directory is not the repository's root.  
- The lowercase letter at the second position is just an "ID" of the specific test. (Like a test number but a letter instead.)
  If there are multiple tests with the same "ID" in a category, they are testing for the same thing.
- The uppercase letter at the third position is the state of the Git `HEAD` during the test:  
  `B` - `HEAD` points to a normal Git branch. (Also, the test name ends with `_-_branch`.)  
  `D` - `HEAD` is detached (it only points to a commit hash). (Also, the test name ends with `_-_detach`.)  
  `O` - `HEAD` doesn't exist because the operation is performed on a freshly created orphan branch. (Also, the test name ends with `_-_orphan`.)  
