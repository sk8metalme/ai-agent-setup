# Quality Assurance Guide

This guide explains how to document comprehensive quality assurance practices in CLAUDE.md.

## Test Strategy

### Testing Pyramid

Document your testing strategy using the test pyramid model:

```markdown
## Testing Strategy

We follow the testing pyramid approach:

```
        /\
       /E2E\      (10% - Critical user journeys)
      /------\
     /Integr.\   (20% - Component integration)
    /----------\
   /   Unit     \  (70% - Business logic, utilities)
  /--------------\
```

### Test Distribution

- **Unit Tests** (70%): Fast, focused tests for individual functions/components
- **Integration Tests** (20%): Test component interactions and API calls
- **E2E Tests** (10%): Critical user journeys through the entire application

### Coverage Requirements

- **Overall**: Minimum 95% coverage
- **Branches**: Minimum 90% coverage
- **Functions**: Minimum 95% coverage
- **Lines**: Minimum 95% coverage
```

### Unit Testing

```markdown
## Unit Testing

### Framework: Jest / Vitest / Pytest

Location: `tests/unit/` or co-located with source files

### Running Tests

```bash
# Run all unit tests
npm test                           # or: pytest

# Run specific test file
npm test src/utils/validation.test.ts

# Watch mode for TDD
npm test -- --watch

# Coverage report
npm run test:coverage
```

### Test Structure

We use AAA pattern (Arrange-Act-Assert):

```typescript
// tests/unit/utils/validation.test.ts
import { validateEmail } from '@/utils/validation'

describe('validateEmail', () => {
  test('accepts valid email addresses', () => {
    // Arrange
    const validEmail = 'user@example.com'

    // Act
    const result = validateEmail(validEmail)

    // Assert
    expect(result).toBe(true)
  })

  test('rejects invalid email addresses', () => {
    const invalidEmails = ['invalid', '@example.com', 'user@', 'user @example.com']

    invalidEmails.forEach(email => {
      expect(validateEmail(email)).toBe(false)
    })
  })

  test('handles edge cases', () => {
    expect(validateEmail('')).toBe(false)
    expect(validateEmail(null)).toBe(false)
    expect(validateEmail(undefined)).toBe(false)
  })
})
```

### Mocking

```typescript
// Mock external dependencies
jest.mock('@/services/api', () => ({
  fetchUser: jest.fn()
}))

import { fetchUser } from '@/services/api'

test('handles API errors gracefully', async () => {
  fetchUser.mockRejectedValueOnce(new Error('Network error'))

  const result = await getUserData(123)

  expect(result).toBeNull()
  expect(console.error).toHaveBeenCalledWith('Failed to fetch user:', expect.any(Error))
})
```

### Coverage Thresholds

```json
// jest.config.js or vitest.config.ts
{
  "coverageThreshold": {
    "global": {
      "branches": 90,
      "functions": 95,
      "lines": 95,
      "statements": 95
    }
  }
}
```
```

### Integration Testing

```markdown
## Integration Testing

Integration tests verify that multiple components work together correctly.

### Testing API Integrations

```typescript
// tests/integration/api.test.ts
import { setupServer } from 'msw/node'
import { rest } from 'msw'
import { fetchUserProfile } from '@/services/userService'

const server = setupServer(
  rest.get('/api/users/:id', (req, res, ctx) => {
    return res(ctx.json({ id: req.params.id, name: 'John Doe' }))
  })
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

test('fetches user profile from API', async () => {
  const profile = await fetchUserProfile('123')

  expect(profile).toEqual({ id: '123', name: 'John Doe' })
})

test('handles API errors', async () => {
  server.use(
    rest.get('/api/users/:id', (req, res, ctx) => {
      return res(ctx.status(500))
    })
  )

  await expect(fetchUserProfile('123')).rejects.toThrow('Failed to fetch user')
})
```

### Database Integration Tests

```python
# tests/integration/test_database.py
import pytest
from myapp import create_app, db
from myapp.models import User

@pytest.fixture
def app():
    app = create_app('testing')
    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()

@pytest.fixture
def client(app):
    return app.test_client()

def test_create_user(client):
    response = client.post('/api/users', json={
        'email': 'test@example.com',
        'name': 'Test User'
    })

    assert response.status_code == 201
    assert User.query.filter_by(email='test@example.com').first() is not None
```
```

### E2E Testing

```markdown
## E2E Testing (Playwright / Cypress)

### Critical User Journeys

Test these paths in every release:

1. **Authentication Flow**
   - Sign up → Email verification → Login
   - Login → Logout
   - Password reset

2. **Core Features**
   - [Project-specific critical path]
   - Example: Shopping cart → Checkout → Payment → Confirmation

3. **Error Scenarios**
   - Invalid input handling
   - Network errors
   - Session expiration

### Running E2E Tests

```bash
# Start application
npm run dev &

# Run all E2E tests
npm run test:e2e

# Run specific test suite
npm run test:e2e tests/e2e/checkout.spec.ts

# Run with UI (debugging)
npm run test:e2e:ui

# Run in different browsers
npm run test:e2e -- --project=chromium
npm run test:e2e -- --project=firefox
npm run test:e2e -- --project=webkit
```

### E2E Test Example

```typescript
// tests/e2e/checkout.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Checkout Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3000')
    // Setup: Add items to cart
  })

  test('complete purchase successfully', async ({ page }) => {
    await page.click('[data-testid="cart-button"]')
    await page.click('text=Proceed to Checkout')

    // Fill shipping information
    await page.fill('[name="email"]', 'customer@example.com')
    await page.fill('[name="address"]', '123 Main St')
    await page.fill('[name="city"]', 'San Francisco')

    // Fill payment information
    await page.fill('[name="cardNumber"]', '4242424242424242')
    await page.fill('[name="expiry"]', '12/25')
    await page.fill('[name="cvc"]', '123')

    // Submit order
    await page.click('button[type="submit"]')

    // Verify success
    await expect(page).toHaveURL(/\/order-confirmation/)
    await expect(page.locator('text=Thank you for your order')).toBeVisible()
  })

  test('validates required fields', async ({ page }) => {
    await page.click('[data-testid="cart-button"]')
    await page.click('text=Proceed to Checkout')
    await page.click('button[type="submit"]')

    await expect(page.locator('text=Email is required')).toBeVisible()
    await expect(page.locator('text=Address is required')).toBeVisible()
  })
})
```

### Visual Regression Testing

```bash
# Capture screenshots
npm run test:e2e -- --update-snapshots

# Compare against baseline
npm run test:e2e
```
```

## Code Quality Tools

### Linting

```markdown
## Linting

### ESLint (JavaScript/TypeScript)

Configuration: `.eslintrc.js`

```bash
# Run linter
npm run lint

# Fix auto-fixable issues
npm run lint:fix

# Lint specific files
npm run lint src/components/**/*.tsx
```

**Rules**: Airbnb style guide + custom overrides

**Key Rules**:
- No unused variables
- Consistent naming conventions
- Import order enforcement
- Max complexity: 10

### Ruff (Python)

Configuration: `pyproject.toml`

```bash
# Run linter
ruff check .

# Auto-fix issues
ruff check --fix .

# Specific files
ruff check src/services/
```

### Custom Rules

Example `.eslintrc.js`:
```javascript
module.exports = {
  extends: ['airbnb', 'airbnb-typescript'],
  rules: {
    'react/react-in-jsx-scope': 'off',  // Not needed in React 17+
    'import/prefer-default-export': 'off',  // Prefer named exports
    'max-len': ['error', { code: 100 }],
    'complexity': ['error', 10]
  }
}
```
```

### Formatting

```markdown
## Code Formatting

### Prettier (JavaScript/TypeScript)

Automatic formatting on save (configured in VS Code/IDE).

```bash
# Format all files
npm run format

# Check formatting
npm run format:check
```

Configuration: `.prettierrc`:
```json
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "es5",
  "tabWidth": 2,
  "printWidth": 100
}
```

### Black (Python)

```bash
# Format all Python files
black .

# Check formatting
black --check .
```

### EditorConfig

`.editorconfig` ensures consistency across editors:
```ini
[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
trim_trailing_whitespace = true
insert_final_newline = true

[*.py]
indent_size = 4
```
```

### Type Checking

```markdown
## Type Checking

### TypeScript

```bash
# Run type checker
npm run type-check

# Watch mode
npm run type-check -- --watch
```

Configuration: `tsconfig.json`:
```json
{
  "compilerOptions": {
    "strict": true,              // Enable all strict checks
    "noUnusedLocals": true,      // Error on unused variables
    "noUnusedParameters": true,  // Error on unused parameters
    "noImplicitReturns": true,   // Ensure all code paths return
    "noFallthroughCasesInSwitch": true
  }
}
```

### Python Type Hints (mypy)

```bash
# Run type checker
mypy src/

# Strict mode
mypy --strict src/
```

Configuration: `pyproject.toml`:
```toml
[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
```
```

## Security Scanning

```markdown
## Security

### Dependency Scanning

```bash
# Audit npm packages
npm audit

# Fix vulnerabilities automatically
npm audit fix

# Python dependencies
pip-audit

# Or use Snyk
snyk test
```

### Secret Scanning

**Git Hooks**: Use `pre-commit` to prevent committing secrets:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
```

**Scan existing code**:
```bash
# Detect secrets in codebase
git secrets --scan
```

### Static Analysis Security Testing (SAST)

```bash
# JavaScript/TypeScript
npm run lint -- --ext .js,.jsx,.ts,.tsx --plugin security

# Python
bandit -r src/
```
```

## Performance Monitoring

```markdown
## Performance

### Bundle Size Monitoring

```bash
# Analyze bundle
npm run build:analyze

# Lighthouse CI (in CI/CD)
lhci autorun
```

**Budget**: Keep main bundle < 200KB gzipped

### Load Time Targets

- **First Contentful Paint (FCP)**: < 1.8s
- **Largest Contentful Paint (LCP)**: < 2.5s
- **Time to Interactive (TTI)**: < 3.8s
- **Cumulative Layout Shift (CLS)**: < 0.1

### Monitoring in CI

```yaml
# .github/workflows/ci.yml
- name: Run Lighthouse
  uses: treosh/lighthouse-ci-action@v9
  with:
    urls: |
      http://localhost:3000
    budgetPath: ./lighthouse-budget.json
    uploadArtifacts: true
```
```

## Quality Gates

```markdown
## Quality Gates (CI/CD)

All PRs must pass these gates before merge:

1. ✅ **Lint**: No linting errors
2. ✅ **Type Check**: No type errors
3. ✅ **Unit Tests**: All passing + 95% coverage
4. ✅ **Integration Tests**: All passing
5. ✅ **E2E Tests**: Critical paths passing
6. ✅ **Build**: Successful production build
7. ✅ **Security**: No high/critical vulnerabilities
8. ✅ **Performance**: Bundle size within budget

**Bypass**: Only allowed for hotfixes with manager approval
```

## Continuous Improvement

```markdown
## Continuous Improvement

### Code Review Metrics

Track and improve:
- Average PR review time (target: < 24 hours)
- Average PR size (target: < 400 lines)
- Number of review iterations (target: < 3)

### Test Maintenance

**Quarterly Review**:
- Remove flaky tests
- Update outdated test data
- Refactor slow tests
- Archive obsolete tests

### Dependency Updates

**Monthly**:
```bash
# Check for updates
npm outdated

# Update dependencies
npm update

# Run tests after updates
npm test && npm run test:e2e
```

**Security patches**: Apply immediately when notified
```

## Best Practices Summary

### Testing

1. **Write tests first** (TDD)
2. **Maintain 95%+ coverage**
3. **Test edge cases** and error scenarios
4. **Run E2E tests** before every PR
5. **Keep tests fast** (unit tests < 5s total)

### Code Quality

1. **Use strict linting** rules
2. **Auto-format on save**
3. **Enable all TypeScript strict checks**
4. **Run linter before commit**
5. **Fix warnings immediately**

### Security

1. **Scan dependencies** regularly
2. **Use Git hooks** to prevent secret leaks
3. **Keep dependencies updated**
4. **Run security audits** weekly
5. **Follow OWASP Top 10** guidelines

### Performance

1. **Monitor bundle size**
2. **Test Core Web Vitals**
3. **Use lazy loading** for large components
4. **Optimize images** and assets
5. **Profile regularly** in production
