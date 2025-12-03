(Read the [general README file for tests](../README.md) first.)

This category (directory) is for tests that check the commands that restore contents of a stash to the working directory.
(`istash apply` and `istash pop`)


### Prefix
The first character of the prefix (sub-category) can be:
- `00` - Sanity tests that don't use git commands from this repository.
- `01` - Popping/Applying without conflicts.
- `02` - Popping/Applying with conflicts that need to be manually solved.
- `03` - Popping/Applying with "conflicts" that can be automatically resolved by Git merge algorithms.
- `04` - Popping/Applying with conflicts and aborting before they are resolved.
- `05` - Popping/Applying with conflicts and quitting before they are resolved.
- `06` - Different ways of specifying which stash to use.
- `07` - Specifying a stash that doesn't exist.
- `08` - Trying to istash when the repository is not in a state that allows that (e.g. an istash is already in progress).
- `09` - Handling various errors.
- `10` - Popping/Applying with sub-directories in the repository and when the working directory is not the repository's root.
