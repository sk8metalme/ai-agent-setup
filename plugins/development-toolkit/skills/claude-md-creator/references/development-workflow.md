# Development Workflow Guide

This guide explains how to document effective development workflows in CLAUDE.md, with emphasis on TDD (Test-Driven Development) and E2E testing.

## Core Development Methodologies

### Test-Driven Development (TDD)

TDD is a development approach where tests are written **before** the implementation code.

**TDD Cycle (Red-Green-Refactor)**:
1. **Red**: Write a failing test
2. **Green**: Write minimum code to pass the test
3. **Refactor**: Improve code while keeping tests green

#### Documenting TDD Workflow

```markdown
## Development Workflow (TDD)

### 1. Write Test First

Create a test file and run it in watch mode:

```bash
# For Jest
npm test -- --watch src/components/Button.test.tsx

# For Pytest
pytest --watch tests/unit/test_auth.py

# For Go
go test -run TestUserLogin ./...
```

Write a failing test:

```typescript
// src/components/Button.test.tsx
import { render, screen } from '@testing-library/react'
import { Button } from './Button'

test('renders button with correct text', () => {
  render(<Button>Click me</Button>)
  expect(screen.getByText('Click me')).toBeInTheDocument()
})
```

### 2. Implement Feature

Write the minimum code to pass the test:

```typescript
// src/components/Button.tsx
export function Button({ children }: { children: React.ReactNode }) {
  return <button>{children}</button>
}
```

### 3. Verify Test Passes

The test should now pass in watch mode.

### 4. Refactor (Optional)

Improve code quality while keeping tests green:
- Extract reusable logic
- Improve naming
- Remove duplication

### 5. Check Coverage

```bash
npm run test:coverage
# Ensure new code has 95%+ coverage
```

### 6. Commit

```bash
git add src/components/Button.tsx src/components/Button.test.tsx
git commit -m "feat(Button): add Button component with click handler"
```
```

### E2E (End-to-End) Testing

E2E tests verify the entire application flow from the user's perspective.

#### Documenting E2E Workflow

```markdown
## E2E Testing Workflow

We use Playwright for E2E tests to ensure critical user journeys work correctly.

### Running E2E Tests

```bash
# Start development server
npm run dev &

# Run E2E tests
npm run test:e2e

# Run specific test file
npm run test:e2e tests/e2e/auth.spec.ts

# Run with UI (debugging)
npm run test:e2e:ui

# Run in headed mode (see browser)
npm run test:e2e -- --headed
```

### Writing E2E Tests

Location: `tests/e2e/`

Example test:

```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from '@playwright/test'

test('user can log in successfully', async ({ page }) => {
  await page.goto('http://localhost:3000')

  await page.click('text=Login')
  await page.fill('[name=email]', 'user@example.com')
  await page.fill('[name=password]', 'password123')
  await page.click('button[type=submit]')

  await expect(page).toHaveURL('http://localhost:3000/dashboard')
  await expect(page.locator('text=Welcome')).toBeVisible()
})
```

### E2E Test Coverage

Critical paths to test:
- [ ] User authentication (login, logout, signup)
- [ ] Core user journeys (e.g., checkout flow, form submission)
- [ ] Error scenarios (invalid input, network errors)
- [ ] Responsive design (mobile, tablet, desktop)

Run E2E tests before creating every PR.
```

## Git Workflow Patterns

### Feature Branch Workflow

Most common pattern for team development.

```markdown
## Git Workflow

### Creating Feature Branch

```bash
# Update main branch
git checkout main
git pull origin main

# Create feature branch from main
git checkout -b feature/user-authentication

# Alternative: Use issue number
git checkout -b feature/123-add-login-page
```

### Development Cycle

1. Write test (TDD)
2. Implement feature
3. Run tests locally
4. Commit changes

```bash
# Stage changes
git add src/auth/login.ts src/auth/login.test.ts

# Commit with conventional commit format
git commit -m "feat(auth): add login functionality

- Add LoginForm component
- Add authentication service
- Add unit and E2E tests

Closes #123"
```

### Before Creating PR

```bash
# Ensure all tests pass
npm test

# Run E2E tests
npm run test:e2e

# Run linter
npm run lint

# Check TypeScript
npm run type-check

# Verify build
npm run build
```

### Creating Pull Request

```bash
# Push branch
git push -u origin feature/user-authentication

# Create PR using GitHub CLI
gh pr create \
  --title "feat: Add user authentication" \
  --body "Implements login/logout functionality. Closes #123"

# Alternative: Create PR via GitHub UI
```

### After PR Review

```bash
# Address review comments
# Make changes, commit, push

# Once approved, squash and merge via GitHub UI
# Delete branch after merge
git checkout main
git pull origin main
git branch -d feature/user-authentication
```
```

### Trunk-Based Development

Alternative to feature branches, optimized for CI/CD.

```markdown
## Git Workflow (Trunk-Based)

We use trunk-based development with short-lived feature branches.

### Rules

- Feature branches live < 2 days
- All code merged to `main` must pass CI
- Deploy to production multiple times per day

### Workflow

```bash
# Create short-lived branch
git checkout -b add-validation

# Make small, focused change
# Write tests, implement, test locally

# Commit and push
git commit -m "feat: add email validation"
git push -u origin add-validation

# Create PR immediately
gh pr create --title "feat: Add email validation" --body "Small focused change"

# After approval (usually within hours), merge
# Delete branch immediately
```

### Feature Flags

For larger features:

```bash
# Use feature flags to hide incomplete features
if (featureFlags.newCheckout) {
  return <NewCheckoutFlow />
} else {
  return <OldCheckoutFlow />
}
```

Configure flags via environment variables or feature flag service.
```

## Code Review Workflow

```markdown
## Code Review Process

### Creating PR

1. Ensure CI passes (tests, linting, type checking)
2. Write clear PR description:
   - What changed
   - Why it changed
   - How to test it
3. Add screenshots for UI changes
4. Link related issues

### Review Checklist

Reviewers check:
- [ ] Tests cover new functionality (95%+ coverage)
- [ ] Code follows project conventions
- [ ] No security vulnerabilities
- [ ] Performance implications considered
- [ ] Documentation updated if needed
- [ ] Backward compatibility maintained

### Addressing Feedback

```bash
# Make requested changes
# Commit and push to same branch
git commit -m "refactor: extract validation logic per review"
git push

# Once approved, merge
```

### Merge Strategy

- **Squash and Merge**: For feature branches (keeps main history clean)
- **Merge Commit**: For release branches (preserves branch history)
- **Rebase and Merge**: For small, atomic commits
```

## Continuous Integration Best Practices

```markdown
## CI Pipeline

### On Every PR

GitHub Actions runs:

1. **Lint Check** (~30s)
   ```bash
   npm run lint
   ```

2. **Type Check** (~45s)
   ```bash
   npm run type-check
   ```

3. **Unit Tests** (~2min)
   ```bash
   npm test -- --coverage
   ```
   Fails if coverage < 95%

4. **Integration Tests** (~3min)
   ```bash
   npm run test:integration
   ```

5. **E2E Tests** (~5min)
   ```bash
   npm run test:e2e
   ```

6. **Build Verification** (~1min)
   ```bash
   npm run build
   ```

**Total time**: ~12 minutes

**Requirements for Merge**: All checks pass + 1 approved review

### On Merge to Main

Automatic deployment to staging environment.

### Nightly

- Full E2E test suite (all browsers)
- Security scans (Snyk, npm audit)
- Dependency updates (Dependabot)
```

## Release Workflow

### Semantic Versioning

```markdown
## Release Process

We follow Semantic Versioning (semver):

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features (backward compatible)
- **PATCH** (1.0.0 → 1.0.1): Bug fixes (backward compatible)

### Creating Release

```bash
# Update version
npm version minor  # or major, patch

# This automatically:
# 1. Updates package.json
# 2. Creates git tag
# 3. Commits changes

# Push tag to trigger release
git push origin v1.2.0

# GitHub Actions auto-publishes to npm/PyPI/etc.
```

### Changelog

Maintained in `CHANGELOG.md` using Conventional Commits:

```markdown
# Changelog

## [1.2.0] - 2024-01-15

### Added
- User authentication with OAuth
- Dark mode support

### Fixed
- Button alignment on mobile devices

### Changed
- Updated dependencies to latest versions
```
```

## Hotfix Workflow

```markdown
## Hotfix Process

For critical production bugs:

```bash
# Create hotfix branch from main (or production tag)
git checkout -b hotfix/fix-payment-bug v1.2.3

# Fix bug with test
# Test locally

# Commit
git commit -m "fix: resolve payment processing error"

# Create PR
gh pr create --title "hotfix: Fix payment processing error"

# After review, merge to main
# Immediately create and push tag
git tag v1.2.4
git push origin v1.2.4

# Auto-deploy to production
```

Hotfix releases skip normal release cycle for critical fixes.
```

## Best Practices Summary

### Development

1. **Always write tests first** (TDD)
2. **Run tests in watch mode** during development
3. **Aim for 95%+ test coverage**
4. **Run E2E tests before PR** creation

### Git

1. **Use conventional commit messages** (feat, fix, docs, etc.)
2. **Keep commits atomic** (one logical change per commit)
3. **Squash before merge** (clean history)
4. **Delete branches after merge**

### CI/CD

1. **All tests must pass** before merge
2. **Coverage threshold enforced** (95%+)
3. **Auto-deploy to staging** on merge
4. **Manual approval for production**

### Code Review

1. **Respond to feedback** within 24 hours
2. **Explain non-obvious decisions** in code comments
3. **Add tests for edge cases** identified in review
4. **Update docs** if behavior changes
