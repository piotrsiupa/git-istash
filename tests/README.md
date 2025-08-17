This directory contain tests and related scripts.
The most notable files (the ones executed by hand) are `run.sh` and `shellcheck.sh`.


# Scripts

## `run.sh` (or `windows-run.bat` for Windows)

The script that runs all the tests placed in this directory.
Executing it without parameters will run all the tests.
(Although, you probably want to add an option `-j0`.)
There are also filtering and formatting options.
(For more information, run `run.sh --help`. Some options can improve the speed significantly.)

## `shellcheck.sh`

A script that checks all the scripts in the projects (including the tests), using `shellcheck`.
(For more information, run `shellcheck.sh --help`.)

## `check-git-versions.sh`

A script that runs the test suite with different versions of Git to determine which ones are supported by `istash`.

## `vanillise-tests.sh`

A simple script that modifies tests to use `git stash` in place of `git istash`.
(Just to see how many of them still passes.)

## `list.sh`
A helper script that just prints the list of tests and allows filtering for essential / no-essential tests.
(It's useful mostly to check if tests were correctly marked as non-essential.)

## `commons.sh`

A helper file with utility functions for implementing tests.
This script is **not** intended to be used outside of tests.
It should be sourced at the beginning of each test file.

### All the remaining scripts

At some point `commons.sh` has got too long and it was split into multiple files.
They are sourced by `commons.sh` and they should be considered part of it.


# Tests

Each test is a shell script saved in a `*.sh` file, in a sub-directory (named the same after the test category).
The file patch relative to the directory `tests` but without the extension is the name of the test.

Tests are scripts that return an exit code `0` if the tests passed and non-`0` otherwise.
To run a test, use the script `run.sh` which will create and initialize a new Git repository in which the test can be safely run.
*Running a test without `run.sh` may mess up files in the Git repository or in the current directory.*
(There is some protection from doing that in the `commons.sh`, but don't try regardless.)

## Test categories

The current test categories are:
- [`main script`](./main_script/README.md) - it covers scenarios that are common to all subcommands of `git istash`.
- [`applying`](./applying/README.md) - it covers `git istash apply` and `git istash pop`.
- [`creating`](./creating/README.md) - it covers `git istash create`, `git istash snatch`, `git istash save` and `git istash push`.
- [`intent-to-add`](./intent-to-add/README.md) - it covers all "applying" and "creating" operations, specifically for files added with the option `--intent-to-add`.

## Test script

Each test starts by sourcing `commons.sh`.
After that there are some normal shell commands to set up the test scenario, usually involving a lot of calls of `git`.
Finally, the tested command is called, which is followed by a bunch of assertions which call a function `fail` if they didn't pass.
(Sometimes, in more complex scenarios, some of these steps repeat a few times.)
(If a test didn't call `fail` and returned non-0, it's still considered failed but there will be no error message. In such cases, use the option `-d` for `run.sh`.)

To fully understand a test, you need to read through [`commons.sh`](./commons.sh) which sets up a test repository and contain the code for all the assertions (among other things).

## Naming convention

`run.sh` doesn't care about tests names beside the extension, but they are also some conventions that serve to simplify sorting, filtering and handling the tests files in general.

Also, note that tests should not use any funny characters that would mess up shell commands and have all spaces replaced by `_`.
(`_` are converted back to ` ` when pretty printing the tests names, and the `/` is converted to ` -> `.)

### Prefix
Each test has 2-character prefix followed by a `_`.
Generally these prefixes work as follows:
- The first character is a digit representing a sub-category of the test.
  (See the `README.md` of a specific test category to learn more.)
- The second character is an uppercase letter that with tandem with the digit acts as an ID of the test in the current directory.
  (In some cases, when there is a lot if tests in the sub-category, there are 2 letters instead of one.)
