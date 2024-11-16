(Read the [general README file for tests](../README.md) first.)

This category (directory) is for tests that check the commands that restore contents of a stash to the working directory.
(`istash apply` and `istash pop`)


### Prefix
The first character of the prefix can be:
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
