This is a guide for the maintainer, acting as a reminder of all the necessary steps required for pushing to the branch `master`.
(Yes, it takes the whole day! Deal with it!)

 1. Make sure the new functionality is finished (including an extensive set of tests for it).
 2. If applicable, remove / fix old tests with "known failures" if these problems are fixed by the new features.
 3. Make sure that `README.md`, `man/man1/git-istash.1` and help texts in `bin/git-istash` and `lib/git-istash/git-istash-*` are up to date with the new features.
 4. Run `tests/shellcheck.sh`.
    (Although, this should really be done after every change in a script.)
 5. Run the complete test suite (`tests/run.sh`) on both Linux and Windows - all tests have to pass.
    (After this step, no changes in directories `bin/` and `lib/` are allowed.)
 6. Run `tests/check-git-versions.sh` to make sure that the minimum required version of `git` hasn't changed.
    (If it did, update `bin/git-istash` and rerun the test suite.)
 7. Switch to latest `master` and merge the feature branch with the flags `--no-ff` and `--no-commit`.
    (If there are conflicts solve them; and rerun the tests and Shellcheck as needed.)
    Do *not* finalize the merge yet.
 8. Update the version numbers in all modified scripts that have a function `print_version`.
    (You may use the script `find-version-numbers-to-update.sh`.)
 9. Update the version number and the date in `man/man1/git-istash.1`.
10. Finalize the merge.
    (Don't forget to include the summary of the changes in the description.)
11. Create a new annotated tag with the version number.
    (Make sure it matches the existing tags.)
12. Push the `master` and the new tag to all the remotes and remove the feature branch everythere.
    (For extra style points, you can use a single atomic push for this.)
