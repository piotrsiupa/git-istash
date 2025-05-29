(Read the [general README file for tests](../README.md) first.)

This category (directory) is for creating and popping stashes when they are files added with the flag `--intent-to-add` (`-N`).
(`istash push`, `istash apply` & `istash pop` - vanilla `git stash` doesn't support that case at all)


### Prefix
The first character of the prefix (sub-category) can be:
- `0` - Sanity tests that don't use git commands from this repository.
  (Except there is no sanity - it's insane how well this works.)
