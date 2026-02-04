---
name: commit
description: Create a git commit following Conventional Commits format
---

# Conventional Commits Skill

Create git commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification.

## Commit Message Format

```
<type>[optional scope]: <subject>

[optional body]

[optional footer(s)]
```

## Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Changes that do not affect the meaning of the code (white-space, formatting, etc.) |
| `refactor` | A code change that neither fixes a bug nor adds a feature |
| `perf` | A code change that improves performance |
| `test` | Adding missing tests or correcting existing tests |
| `ci` | Changes to CI configuration files and scripts |
| `chore` | Other changes that don't modify src or test files |
| `revert` | Reverts a previous commit |

## Rules

- **type**: Required. Must be one of the types listed above (lowercase).
- **scope**: Optional. A noun describing a section of the codebase (e.g., `api`, `ui`, `auth`).
- **subject**: Required. A short description of the change.
  - Use imperative, present tense: "add" not "added" nor "adds"
  - Don't capitalize the first letter
  - No period at the end
- **body**: Optional. A longer description providing additional context.
  - Separated from subject by a blank line
  - Explain what and why, not how
- **footer**: Optional. Used for breaking changes or issue references.
  - `BREAKING CHANGE: <description>` for breaking changes
  - `Refs: #123` or `Closes: #123` for issue references

## Instructions

When the user invokes `/commit`:

1. Run `git status` and `git diff --staged` to see staged changes
2. If no changes are staged, run `git diff` to see unstaged changes and ask if the user wants to stage them
3. Analyze the changes and determine the appropriate type and scope
4. Generate a commit message following the Conventional Commits format
5. If `$ARGUMENTS` is provided, use it as guidance for the commit message
6. Show the proposed commit message to the user and ask for confirmation
7. Create the commit with the approved message

## Arguments

`$ARGUMENTS` - Optional guidance or context for generating the commit message.

## Examples

```
feat(auth): add OAuth2 login support

Implement OAuth2 authentication flow with Google and GitHub providers.

Refs: #42
```

```
fix: resolve null pointer exception in user service

The user lookup was not handling the case where the user ID
was not found in the database.

Closes: #123
```

```
docs: update API documentation for v2 endpoints
```

```
refactor(api)!: rename getUserById to findUser

BREAKING CHANGE: The getUserById function has been renamed to findUser
and now returns an Optional<User> instead of User.
```
