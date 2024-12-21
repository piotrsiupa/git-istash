(Read the [general README file for tests](../README.md) first.)

This category (directory) is for tests that check the commands that create a new stash.
(`istash push`)


### Prefix
The first character of the prefix can be:
- `0` - Sanity tests that don't use git commands from this repository.
- `1` - Creating stashes with different flags.
- `2` - Option `--patch`.
- `3` - Validating pathspecs.
- `4` - Pathspecs.
- `5` - Tricky/corner cases and miscellaneous options.
