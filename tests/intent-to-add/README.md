(Read the [general README file for tests](../README.md) first.)

This category (directory) is for creating and popping stashes when they are files added with the flag `--intent-to-add` (`-N`).
(`istash push`, `istash apply` & `istash pop` - Vanilla `git stash` doesn't support that case at all so we need to test pushing and popping at the same time.)


### Prefix
The first character of the prefix (sub-category) can be:
- `0` - Sanity tests that don't use git commands from this repository.
- `1` - Creating stashes with different flags.
- `2` - Option `--patch`.
- `3` - Pathspecs.
- `4` - Tricky/corner cases and miscellaneous.
- `5` - Sub-directories.
