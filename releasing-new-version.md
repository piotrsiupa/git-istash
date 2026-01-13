This is a guide for the maintainer, acting as a reminder of all the necessary steps required for pushing to the branch `master`.
(Yes, it takes the whole day! Deal with it!)

 1. Make sure the new functionality is finished (including an extensive set of tests for it).
 2. If applicable, remove / fix old tests with "known failures" if these problems are fixed by the new features.
 3. Make sure that `README.md`, `man/man1/git-istash.1` and help texts in `bin/git-istash` and `lib/git-istash/git-istash-*` are up to date with the new features.
 4. Make sure that there are no TODO comments remaining in the working copy or committed by accident.
 5. Switch to latest `master` and merge the feature branch with the flags `--no-ff` and `--no-commit`.
    Do *not* finalize the merge yet.
 6. Fix merge conflicts.
    If there are a lot of them, or there are a lot changes on master that are not in the branch yet, consider a preliminary merge of master into the branch.
 7. Run `tests/shellcheck.sh`.
    (Although, this should really be done after every change in a script.)
 8. Run the complete test suite (`tests/run.sh`) on both Linux and Windows - all tests have to pass.
    Make sure to choose a meticulousness that will catch all the problems that may be introduced by the new changes.
    For simple changes `complete` may suffice but you should run `full` (or at the very least `standard`) on at least one system, and maybe even `full|options,partial-options` if there is a chance that the new option names will collide in any way (including their abbreviations).
    (For Windows run `quickie` and with some luck this won't take the whole day.)
    After this step, no changes in directories `bin/` and `lib/` are allowed.
 9. Run `tests/check-git-versions.sh` to make sure that the minimum required version of `git` hasn't changed.
    (If it did, update `bin/git-istash` and rerun the test suite.)
10. Update the version numbers in all modified scripts that have a function `print_version`.
    (You may use the script `find-version-numbers-to-update.sh`.)
11. Update the version number and the date in `man/man1/git-istash.1`.
12. Finalize the merge.
    (Don't forget to include the summary of the changes in the description.)
13. Create a new annotated tag with the version number.
    (Make sure it matches the existing tags.)
14. Push the `master` and the new tag to all the remotes and remove the feature branch everywhere.
    (For extra style points, you can use a single atomic push for each remote.)
