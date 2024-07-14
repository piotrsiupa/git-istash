This directory contains sources for man pages for the project.
Because it's not a good idea to store binary files in Git (especially if they are really text files for which you want to have diffs), uncompressed files are committed instead.

# `build.sh`
This scripts compress the man source files using gzip (which turns them into proper man pages) and puts them into the directory `share/man/` in the project's root.
(Be careful to not edit the output files by accident; they aren't tracked by Git.)

# `display.sh`
This script runs `build.sh` and then displays the page for `git-istash` (which is currently the only page) in the program `man`.
It can be used to verify that the page contents are displayed correctly.
