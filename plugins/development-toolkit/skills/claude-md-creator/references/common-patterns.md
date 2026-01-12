# Common Patterns Guide

This guide provides reusable patterns and snippets for CLAUDE.md documentation.

## Environment Variables Pattern

### Template

```markdown
## Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# API Keys (get from respective dashboards)
STRIPE_SECRET_KEY=sk_test_xxx               # Stripe Dashboard → API Keys
SENDGRID_API_KEY=SG.xxx                     # SendGrid → Settings → API Keys

# Application
NODE_ENV=development                        # development | staging | production
PORT=3000                                   # Server port
LOG_LEVEL=debug                             # debug | info | warn | error

# Feature Flags (optional)
FEATURE_NEW_CHECKOUT=false                  # Enable new checkout flow
FEATURE_ANALYTICS=true                      # Enable analytics tracking
```

**Security**:
- `.env` is gitignored (never commit)
- Use different values for dev/staging/prod
- Store production secrets in deployment platform (Vercel, Railway, etc.)

**Required Variables**: All variables without "optional" comment are required
**Optional Variables**: Marked with "optional" comment
```

### Validation Script

```markdown
### Environment Validation

Run validation script before starting:

```bash
npm run validate:env  # Checks all required variables are set
```

Or manually:
```bash
node -e "require('dotenv').config(); ['DATABASE_URL', 'API_KEY'].forEach(k => { if (!process.env[k]) throw new Error(\`Missing \${k}\`) })"
```
```

## Command Reference Pattern

### Categorized Commands

```markdown
## Common Commands

### Development
| Command | Description | Example Output |
|---------|-------------|----------------|
| `npm run dev` | Start dev server | Running at http://localhost:3000 |
| `npm run dev:debug` | Start with debugger | Debugger listening on ws://localhost:9229 |
| `npm run dev:host` | Expose to network | Running at http://192.168.1.100:3000 |

### Testing
| Command | Description | Coverage Requirement |
|---------|-------------|---------------------|
| `npm test` | Run all tests | - |
| `npm test -- --watch` | Watch mode (TDD) | - |
| `npm run test:coverage` | Coverage report | 95%+ required |
| `npm run test:e2e` | E2E tests | Critical paths only |

### Code Quality
| Command | Description | Autofixes |
|---------|-------------|-----------|
| `npm run lint` | Run ESLint | No |
| `npm run lint:fix` | Auto-fix issues | Yes |
| `npm run type-check` | TypeScript check | No |
| `npm run format` | Prettier format | Yes |

### Build
| Command | Description | Output |
|---------|-------------|--------|
| `npm run build` | Production build | `dist/` |
| `npm run build:analyze` | Analyze bundle | Opens visualizer |
| `npm run preview` | Preview build | http://localhost:4173 |

### Database
| Command | Description | Destructive |
|---------|-------------|-------------|
| `npm run db:migrate` | Run migrations | No |
| `npm run db:seed` | Seed database | No |
| `npm run db:reset` | Reset database | ⚠️  Yes |
```

## Prerequisites Pattern

### With Version Checks

```markdown
## Prerequisites

Required tools (must be in `$PATH`):

| Tool | Version | Check Command | Install |
|------|---------|---------------|---------|
| Node.js | >= 20.0.0 | `node --version` | [nodejs.org](https://nodejs.org) |
| npm | >= 10.0.0 | `npm --version` | Included with Node.js |
| Docker | >= 24.0.0 | `docker --version` | [docker.com](https://docker.com/get-started) |
| PostgreSQL | >= 15.0 | `psql --version` | [postgresql.org](https://postgresql.org/download) |

**Verification Script**:
```bash
# Check all prerequisites
./scripts/check-prereqs.sh

# Or manually:
for cmd in node npm docker psql; do
  command -v $cmd >/dev/null 2>&1 || echo "❌ $cmd not found"
done
```

**Optional Tools** (enhanced development experience):
- `docker-compose` >= 2.20.0 - Multi-container orchestration
- `jq` >= 1.6 - JSON processing for scripts
```

## Quick Start Pattern

### Numbered Steps

```markdown
## Quick Start

Get the application running in 5 minutes:

**1. Clone Repository**
```bash
git clone https://github.com/user/repo.git
cd repo
```

**2. Install Dependencies**
```bash
npm install
# Expected: ~2 minutes, ~500 packages
```

**3. Configure Environment**
```bash
cp .env.example .env
# Edit .env with your database credentials
```

**4. Start Database**
```bash
docker-compose up -d postgres redis
# Verify: docker-compose ps
```

**5. Run Migrations**
```bash
npm run db:migrate
# Expected: 15 migrations applied
```

**6. Seed Data (Optional)**
```bash
npm run db:seed
# Creates: 10 users, 50 posts, 200 comments
```

**7. Start Development Server**
```bash
npm run dev
# Opens: http://localhost:3000
```

**Verification**:
- Visit http://localhost:3000
- Login with: `admin@example.com` / `password123`
- You should see the dashboard

**Troubleshooting**:
- Database connection fails? Check Docker is running: `docker ps`
- Port 3000 already in use? Change `PORT` in `.env`
- Migrations fail? Reset database: `npm run db:reset`
```

## Testing Strategy Pattern

### TDD Workflow

```markdown
## Testing Strategy

We follow Test-Driven Development (TDD):

### Test Pyramid

```
      E2E (10%)         ← Critical user journeys
    Integration (20%)   ← Component interaction
  Unit Tests (70%)      ← Business logic
```

### Coverage Requirements

| Type | Target | Command |
|------|--------|---------|
| Overall | 95%+ | `npm run test:coverage` |
| New Code | 100% | Enforced in CI |
| Branches | 90%+ | - |

### Running Tests

**During Development (TDD)**:
```bash
# 1. Write failing test
npm test -- --watch src/utils/validation.test.ts

# 2. Implement feature (test turns green)

# 3. Refactor (keep tests green)
```

**Before Commit**:
```bash
npm test                # All unit tests (~5s)
npm run test:integration # Integration tests (~30s)
npm run test:e2e        # E2E tests (~2min)
```

**Coverage Report**:
```bash
npm run test:coverage
# Output: coverage/lcov-report/index.html
open coverage/lcov-report/index.html
```

### Writing Tests

**Unit Test Example**:
```typescript
// src/utils/validation.test.ts
import { validateEmail } from './validation'

describe('validateEmail', () => {
  it('accepts valid emails', () => {
    expect(validateEmail('user@example.com')).toBe(true)
  })

  it('rejects invalid emails', () => {
    expect(validateEmail('invalid')).toBe(false)
    expect(validateEmail('')).toBe(false)
  })
})
```

**E2E Test Example**:
```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from '@playwright/test'

test('user can log in', async ({ page }) => {
  await page.goto('http://localhost:3000')
  await page.click('text=Login')
  await page.fill('[name=email]', 'user@example.com')
  await page.fill('[name=password]', 'password123')
  await page.click('button[type=submit]')
  await expect(page).toHaveURL('/dashboard')
})
```
```

## Deployment Pattern

### Multi-Environment

```markdown
## Deployment

### Environments

| Environment | URL | Branch | Auto-Deploy | Health Check |
|-------------|-----|--------|-------------|--------------|
| Development | http://localhost:3000 | - | Manual | - |
| Staging | https://staging.example.com | `develop` | ✅ Yes | 2min warmup |
| Production | https://example.com | `main` | ⚠️  Approval Required | 5min warmup |

### Deployment Workflow

**Staging** (automatic):
```bash
# Merge to develop
git checkout develop
git merge feature/new-feature
git push origin develop

# GitHub Actions auto-deploys to staging
# URL: https://staging.example.com
# Time: ~5 minutes
```

**Production** (manual approval):
```bash
# Create release PR: develop → main
gh pr create --base main --head develop \
  --title "Release v1.2.0" \
  --body "$(./scripts/generate-release-notes.sh)"

# After PR approval, merge
# Deployment requires manual approval in GitHub Actions
# Approver: Team lead or senior engineer
# URL: https://example.com
# Time: ~8 minutes (includes health checks)
```

### Rollback

**Staging**:
```bash
# Revert commit in develop
git revert <commit-hash>
git push origin develop
# Auto-deploys reverted version
```

**Production**:
```bash
# Via GitHub UI
# Actions → Latest deployment → Re-run previous deployment

# Or via CLI
gh workflow run deploy.yml --ref <previous-commit-hash>
```

### Health Checks

After deployment:
```bash
# Check application health
curl https://example.com/health

# Expected response:
# {
#   "status": "healthy",
#   "version": "1.2.0",
#   "database": "connected",
#   "redis": "connected"
# }
```
```

## Troubleshooting Pattern

### FAQ Style

```markdown
## Troubleshooting

### Common Issues

**Issue**: Database connection fails with "Connection refused"

**Cause**: PostgreSQL is not running

**Solution**:
```bash
# Check if Docker container is running
docker-compose ps

# If not running, start it
docker-compose up -d postgres

# Verify connection
psql -h localhost -U postgres -d myapp_dev
```

---

**Issue**: `npm install` fails with EACCES error

**Cause**: Permission issues with npm global folder

**Solution**:
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules

# Or use nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

---

**Issue**: Tests fail with "Port 3000 already in use"

**Cause**: Previous dev server still running

**Solution**:
```bash
# Find and kill process on port 3000
lsof -ti:3000 | xargs kill

# Or use different port
PORT=3001 npm run dev
```

---

**Issue**: Build fails with "Out of memory"

**Cause**: Insufficient Node.js heap size

**Solution**:
```bash
# Increase heap size
export NODE_OPTIONS="--max-old-space-size=4096"
npm run build

# Or add to package.json scripts:
"build": "NODE_OPTIONS='--max-old-space-size=4096' vite build"
```

### Getting Help

If you encounter an issue not listed here:

1. Check GitHub Issues: https://github.com/user/repo/issues
2. Search Stack Overflow with tag: `[project-name]`
3. Ask in Slack channel: #engineering-help
4. Create new issue with: `npm run bug-report`
```

## Architecture Overview Pattern

### Component Diagram

```markdown
## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────┐
│                       Frontend                          │
│  React + TypeScript + Vite + TailwindCSS + Zustand     │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/REST
                     │
┌────────────────────▼────────────────────────────────────┐
│                    Backend API                          │
│         Node.js + Express + TypeScript                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐   │
│  │   Auth       │ │   Users      │ │   Posts      │   │
│  │   Service    │ │   Service    │ │   Service    │   │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘   │
└─────────┼────────────────┼────────────────┼────────────┘
          │                │                │
          └────────────────┼────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                  PostgreSQL Database                    │
│           Tables: users, posts, comments                │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Request → Frontend → API Gateway → Service Layer → Database
             ←          ←              ←               ←
           Response   JSON            Business Logic  Data
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend | React 18 + TypeScript | UI components |
| State | Zustand | Client state management |
| Styling | TailwindCSS | Utility-first CSS |
| Backend | Node.js 20 + Express | REST API |
| Database | PostgreSQL 15 | Data persistence |
| Cache | Redis 7 | Session & cache storage |
| Search | Elasticsearch 8 | Full-text search |
```

## Git Workflow Pattern

### Visual Diagram

```markdown
## Git Workflow

### Branch Strategy (GitHub Flow)

```
main (production)
  │
  ├─── feature/auth ──→ PR ──→ merge
  │
  ├─── feature/dark-mode ──→ PR ──→ merge
  │
  └─── hotfix/critical-bug ──→ PR ──→ merge
```

### Workflow Steps

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/user-profile
   ```

2. **Develop with TDD**
   ```bash
   npm test -- --watch  # Write test → Implement → Refactor
   ```

3. **Commit Changes**
   ```bash
   git commit -m "feat(profile): add user profile page"
   ```

4. **Push & Create PR**
   ```bash
   git push -u origin feature/user-profile
   gh pr create --title "feat: Add user profile page"
   ```

5. **Code Review**
   - Reviewer checks code quality, tests, security
   - CI runs: lint, type-check, tests, build

6. **Merge (Squash and Merge)**
   - Via GitHub UI after approval
   - Auto-deploys to staging

7. **Cleanup**
   ```bash
   git checkout main
   git pull origin main
   git branch -d feature/user-profile
   ```
```

## Performance Budgets Pattern

```markdown
## Performance Budgets

We enforce performance budgets in CI:

### Bundle Size

| Resource | Budget | Current | Status |
|----------|--------|---------|--------|
| Main JS | 200 KB | 185 KB | ✅ Pass |
| Main CSS | 50 KB | 42 KB | ✅ Pass |
| Total Assets | 500 KB | 450 KB | ✅ Pass |

### Core Web Vitals

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| FCP (First Contentful Paint) | < 1.8s | 1.2s | ✅ Pass |
| LCP (Largest Contentful Paint) | < 2.5s | 2.1s | ✅ Pass |
| TTI (Time to Interactive) | < 3.8s | 3.2s | ✅ Pass |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.05 | ✅ Pass |

### Monitoring

```bash
# Analyze bundle size
npm run build:analyze

# Run Lighthouse
npm run lighthouse

# CI fails if budgets exceeded
```
```

## Security Checklist Pattern

```markdown
## Security Checklist

Before deploying to production:

### Code Security
- [ ] No hardcoded secrets (API keys, passwords)
- [ ] Environment variables used for all configs
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output escaping)
- [ ] CSRF protection enabled

### Dependencies
- [ ] No high/critical vulnerabilities (`npm audit`)
- [ ] Dependencies up to date (`npm outdated`)
- [ ] No deprecated packages

### Authentication & Authorization
- [ ] Strong password requirements
- [ ] JWT tokens expire (< 24h)
- [ ] Refresh token rotation implemented
- [ ] Rate limiting on auth endpoints

### Data Protection
- [ ] HTTPS everywhere
- [ ] Secure cookies (httpOnly, secure, sameSite)
- [ ] Personal data encrypted at rest
- [ ] Database backups configured

### Monitoring
- [ ] Error tracking (Sentry)
- [ ] Security headers configured (Helmet.js)
- [ ] Logging implemented (no sensitive data logged)
- [ ] Alerts configured for suspicious activity

Run security check:
```bash
npm run security:check  # Runs audit, lint security rules, etc.
```
```

## Best Practices

1. **Be Specific**: Use actual commands, file paths, URLs
2. **Show Examples**: Include real code snippets
3. **Provide Context**: Explain why, not just what
4. **Keep Updated**: Review and update quarterly
5. **Visual Aids**: Use ASCII diagrams, tables, trees
6. **Searchable**: Use clear headings and keywords
7. **Testable**: Include verification steps
8. **Actionable**: Every section should enable action
