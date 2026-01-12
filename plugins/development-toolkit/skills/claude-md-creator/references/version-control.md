# Version Control Guide

This guide explains how to document Git and Jujutsu (jj) version control strategies in CLAUDE.md.

## Git Strategies

### Branch Strategies

#### Git Flow (Traditional)

```markdown
## Git Branch Strategy (Git Flow)

We use Git Flow for structured release management.

### Branch Types

- **main**: Production code (always deployable)
- **develop**: Integration branch for next release
- **feature/***: New features (branch from develop)
- **release/***: Release preparation (branch from develop)
- **hotfix/***: Emergency fixes (branch from main)

### Workflow

**New Feature**:
```bash
# Start feature
git checkout develop
git pull origin develop
git checkout -b feature/user-authentication

# Develop and commit
git add .
git commit -m "feat(auth): add login functionality"

# Finish feature
git checkout develop
git pull origin develop
git merge --no-ff feature/user-authentication
git push origin develop
git branch -d feature/user-authentication
```

**Release**:
```bash
# Create release branch
git checkout develop
git checkout -b release/1.2.0

# Bump version, update changelog
npm version 1.2.0

# Merge to main and develop
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin main --tags

git checkout develop
git merge --no-ff release/1.2.0
git push origin develop

git branch -d release/1.2.0
```

**Hotfix**:
```bash
# Create hotfix from main
git checkout main
git checkout -b hotfix/critical-bug

# Fix and commit
git add .
git commit -m "fix: resolve critical payment bug"

# Merge to main and develop
git checkout main
git merge --no-ff hotfix/critical-bug
git tag -a v1.2.1 -m "Hotfix v1.2.1"
git push origin main --tags

git checkout develop
git merge --no-ff hotfix/critical-bug
git push origin develop

git branch -d hotfix/critical-bug
```

### Branch Protection

**main**:
- Require pull request reviews (minimum 1)
- Require status checks to pass
- No direct pushes
- No force pushes

**develop**:
- Require pull request reviews
- Require status checks to pass
```

#### GitHub Flow (Simplified)

```markdown
## Git Branch Strategy (GitHub Flow)

We use GitHub Flow for continuous deployment.

### Branches

- **main**: Production code (always deployable)
- **feature/***: All changes (features, fixes, etc.)

### Workflow

```bash
# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/add-dark-mode

# Make changes and commit
git add .
git commit -m "feat: add dark mode toggle"

# Push and create PR
git push -u origin feature/add-dark-mode
gh pr create --title "feat: Add dark mode" --body "Implements dark mode toggle in settings"

# After PR approval, merge via GitHub UI (squash and merge)
# Delete branch after merge

# Update local main
git checkout main
git pull origin main
git branch -d feature/add-dark-mode
```

### When to Use

- **GitHub Flow**: Simple projects, continuous deployment
- **Git Flow**: Complex projects, scheduled releases
```

#### Trunk-Based Development

```markdown
## Git Branch Strategy (Trunk-Based)

We practice trunk-based development for fast iteration.

### Principles

- Main branch (trunk) is always releasable
- Short-lived feature branches (< 2 days)
- Frequent integration to main
- Feature flags for incomplete features

### Workflow

```bash
# Create short-lived branch
git checkout main
git pull origin main
git checkout -b add-email-validation

# Make focused change (small scope!)
git add .
git commit -m "feat: add email validation"

# Push and create PR immediately
git push -u origin add-email-validation
gh pr create --title "feat: Add email validation"

# Merge within hours, not days
# Delete branch after merge

# Update main
git checkout main
git pull origin main
git branch -d add-email-validation
```

### Feature Flags

For larger features:

```typescript
// Use feature flags to hide incomplete work
if (featureFlags.newCheckoutFlow) {
  return <NewCheckoutFlow />
} else {
  return <OldCheckoutFlow />
}
```

Enable via environment variables:
```
FEATURE_NEW_CHECKOUT=true  # Enable in dev/staging
FEATURE_NEW_CHECKOUT=false # Disabled in production
```
```

### Commit Message Conventions

#### Conventional Commits

```markdown
## Commit Message Format (Conventional Commits)

We use Conventional Commits for automated changelogs and semantic versioning.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style (formatting, semicolons, etc.)
- **refactor**: Code refactoring (no feat or fix)
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Build process, dependencies, etc.
- **ci**: CI/CD changes

### Examples

**Feature**:
```
feat(auth): add OAuth login

Implement OAuth 2.0 authentication flow with Google and GitHub providers.

Closes #123
```

**Bug Fix**:
```
fix(cart): prevent duplicate items

Fixed issue where adding same product twice created duplicate entries.

Fixes #456
```

**Breaking Change**:
```
feat(api)!: change user endpoint response format

BREAKING CHANGE: User API now returns `id` instead of `userId`

Closes #789
```

### Automated Tools

**commitlint**: Enforce commit message format
```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

**commitizen**: Interactive commit message prompts
```bash
npm install --save-dev commitizen
npx cz  # Run to create commit
```
```

### Semantic Versioning

```markdown
## Semantic Versioning

We follow [SemVer](https://semver.org/): MAJOR.MINOR.PATCH

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features (backward compatible)
- **PATCH** (1.0.0 → 1.0.1): Bug fixes (backward compatible)

### Automatic Versioning

Using Conventional Commits:
- `feat:` → MINOR version bump
- `fix:` → PATCH version bump
- `BREAKING CHANGE:` or `!` → MAJOR version bump

**standard-version** automates this:
```bash
npm install --save-dev standard-version

# Bump version, update CHANGELOG, create git tag
npm run release
```
```

## Git Best Practices

### General Guidelines

```markdown
## Git Best Practices

### Commits

1. **Atomic Commits**: One logical change per commit
2. **Meaningful Messages**: Explain why, not just what
3. **Small Commits**: Easier to review and revert
4. **Test Before Commit**: Ensure code compiles and tests pass

### Branches

1. **Short-Lived**: Merge within 2-3 days max
2. **Descriptive Names**: `feature/user-authentication` not `fix-stuff`
3. **Delete After Merge**: Keep repository clean
4. **Sync Regularly**: Pull from main/develop daily

### Pull Requests

1. **Small PRs**: < 400 lines changed (easier to review)
2. **Clear Description**: What, why, how to test
3. **Link Issues**: Reference issue numbers
4. **Request Review**: Don't merge your own PR

### Merging

1. **Squash and Merge**: For feature branches (clean history)
2. **Merge Commit**: For release branches (preserve history)
3. **Rebase Before Merge**: Update feature branch with main

### Security

1. **Never Commit Secrets**: Use .gitignore and .env files
2. **Sign Commits**: Use GPG for commit signing
3. **Review Before Push**: Double-check what you're pushing
```

### Git Hooks

```markdown
## Git Hooks

We use Git hooks for quality checks.

### pre-commit

Install: `npm install --save-dev husky lint-staged`

Configuration (.husky/pre-commit):
```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npx lint-staged
```

Configuration (package.json):
```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write",
      "npm test -- --findRelatedTests --passWithNoTests"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

### pre-push

Prevent pushing if tests fail:
```bash
#!/bin/sh
npm test
```

### commit-msg

Enforce conventional commit format:
```bash
#!/bin/sh
npx --no -- commitlint --edit $1
```
```

## Jujutsu (jj) Workflows

### Introduction to Jujutsu

```markdown
## Jujutsu (jj) Version Control

We use Jujutsu (jj) as an alternative to Git, with improved UX and built-in conflict resolution.

### Why Jujutsu?

- **Automatic Commits**: Every change creates a commit (no staging area)
- **Easy Undo**: Safe to experiment, easy to undo
- **Conflict Resolution**: Better merge conflict handling
- **Git Compatible**: Works with Git repositories

### Installation

```bash
# macOS
brew install jj

# Verify
jj version
```

### Basic Workflow

```bash
# Clone repository
jj git clone https://github.com/user/repo.git
cd repo

# Create new change (like git checkout -b)
jj new -m "Add user authentication"

# Make changes (automatically committed)
# Edit files...

# Describe your change (like git commit --amend)
jj describe -m "feat(auth): add login functionality"

# Create new change for next task
jj new -m "Add password reset"

# Push to GitHub
jj git push --branch main
```

### Common Commands

```bash
# View changes
jj status                    # Current change status
jj log                       # Commit history (like git log)
jj diff                      # View changes

# Working with changes
jj new                       # Create new change
jj edit <change-id>          # Edit existing change
jj squash                    # Squash into parent change

# Branching
jj branch create feature/auth
jj branch list
jj branch set main

# Syncing
jj git fetch                 # Fetch from remote
jj git push                  # Push to remote
jj rebase -d main            # Rebase on main

# Undo
jj undo                      # Undo last operation
jj op log                    # View operation history
jj op restore <operation-id> # Restore to previous state
```

### Jujutsu Best Practices

1. **Describe Changes**: Use `jj describe` to add meaningful commit messages
2. **Create Bookmarks**: Use bookmarks (like Git branches) for features
3. **Regular Sync**: Fetch and rebase regularly
4. **Use Change IDs**: Reference changes by ID, not hash
5. **Experiment Freely**: Easy to undo mistakes with `jj undo`

### Converting from Git

If migrating from Git:

```bash
# Inside Git repository
jj git init --colocate  # Initialize jj alongside Git

# Continue using both
jj status               # Jujutsu commands
git status              # Git commands still work

# Eventually move fully to jj
```
```

### Jujutsu Workflow Patterns

```markdown
## Jujutsu Development Workflow

### Feature Development

```bash
# Start new feature
jj bookmark create feature/user-profile
jj new -m "Add user profile page"

# Make changes (auto-committed)
# Edit files...

# Describe change
jj describe -m "feat(profile): add user profile page

- Add ProfilePage component
- Add profile API integration
- Add unit and E2E tests"

# Create additional changes for the feature
jj new -m "Add profile edit functionality"
# Make changes...
jj describe -m "feat(profile): add profile editing"

# Squash changes together if needed
jj squash

# Push feature
jj git push --branch feature/user-profile
```

### Reviewing Changes

```bash
# View commit graph
jj log

# View specific change
jj show <change-id>

# View changes in current working copy
jj diff

# View changes between two commits
jj diff -r <from>..<to>
```

### Conflict Resolution

Jujutsu has better conflict handling:

```bash
# After rebase, if conflicts occur
jj status              # Shows conflicting files

# Edit conflicting files
# Jujutsu marks conflicts differently than Git

# After resolving
jj resolve             # Mark conflicts as resolved
```

### Undo/Redo

```bash
# Undo last operation
jj undo

# View operation history
jj op log

# Restore to specific operation
jj op restore <op-id>

# Abandon a change
jj abandon <change-id>
```

### Integration with GitHub

```bash
# Create PR
jj git push --branch feature/auth
gh pr create --title "Add authentication"

# Update PR after review
jj edit <change-id>      # Edit change
# Make changes...
jj git push --force --branch feature/auth

# After PR merge
jj git fetch
jj rebase -d main
```
```

## Best Practices Summary

### Git

1. **Commit Often**: Small, atomic commits
2. **Write Good Messages**: Conventional Commits format
3. **Branch Strategy**: Choose one and stick to it
4. **Code Review**: Always review before merge
5. **Keep Clean**: Delete merged branches

### Jujutsu

1. **Describe Changes**: Add messages with `jj describe`
2. **Use Bookmarks**: Track features with bookmarks
3. **Undo Freely**: Don't fear mistakes, easy to undo
4. **Sync Regularly**: Fetch and rebase often
5. **Leverage Change IDs**: Use stable change IDs

### Both

1. **Never Commit Secrets**
2. **Sign Your Commits** (GPG)
3. **Review Before Push**
4. **Document Your Workflow** in CLAUDE.md
5. **Use Hooks** for quality checks
