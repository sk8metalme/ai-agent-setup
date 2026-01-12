# CLAUDE.md Examples

This document provides real-world examples of effective CLAUDE.md files for different project types.

## Example 1: React Web Application

```markdown
# E-Commerce Dashboard

Modern admin dashboard for managing e-commerce operations. Built with React, TypeScript, and Vite.

**Tech Stack**: React 18, TypeScript, Vite, TailwindCSS, React Query, Zustand

## Quick Start

Prerequisites:
- `node` >= 18.0.0
- `npm` >= 9.0.0

```bash
npm install
cp .env.example .env  # Configure environment variables
npm run dev           # Start at http://localhost:5173
```

## Common Commands

### Development
- `npm run dev` - Start dev server
- `npm run dev:host` - Start with network access
- `npm run type-check` - TypeScript validation

### Testing (TDD Required)
- `npm test` - Run unit tests (Vitest)
- `npm test -- --watch` - Watch mode for TDD
- `npm run test:e2e` - E2E tests (Playwright)
- `npm run test:coverage` - Coverage report (target: 95%+)

### Code Quality
- `npm run lint` - ESLint check
- `npm run lint:fix` - Auto-fix issues
- `npm run format` - Prettier formatting

### Build
- `npm run build` - Production build
- `npm run preview` - Preview production build

## Project Structure

```
src/
├── components/       # Reusable UI components
│   ├── ui/          # Base components (Button, Input, etc.)
│   └── features/    # Feature-specific components
├── pages/           # Page components (React Router)
├── hooks/           # Custom hooks
├── stores/          # Zustand state stores
├── services/        # API calls
├── utils/           # Utilities
└── types/           # TypeScript types

tests/
├── unit/           # Unit tests (co-located with source)
└── e2e/            # E2E tests (Playwright)
```

**Key Files**:
- `src/main.tsx` - App entry point
- `src/App.tsx` - Root component + routing
- `src/config.ts` - App configuration
- `vite.config.ts` - Build config

## Development Workflow (TDD)

### 1. Create Feature Branch

```bash
git checkout -b feature/product-filtering
```

### 2. Write Test First

```bash
# Create test
touch src/components/features/ProductFilter.test.tsx

# Run in watch mode
npm test -- --watch src/components/features/ProductFilter.test.tsx
```

Example test:
```typescript
import { render, screen } from '@testing-library/react'
import { ProductFilter } from './ProductFilter'

test('filters products by category', () => {
  render(<ProductFilter />)
  // Test implementation
})
```

### 3. Implement Feature

Write minimum code to pass the test in `src/components/features/ProductFilter.tsx`

### 4. Verify Coverage

```bash
npm run test:coverage
# Ensure new code has 95%+ coverage
```

### 5. Run E2E Tests

```bash
npm run dev &            # Start dev server
npm run test:e2e         # Run E2E tests
```

### 6. Create PR

```bash
git commit -m "feat(filter): add product category filter"
gh pr create --title "feat: Add product category filter"
```

## CI/CD

### GitHub Actions

Every PR runs:
1. Lint (`npm run lint`)
2. Type check (`npm run type-check`)
3. Unit tests (`npm test`)
4. E2E tests (`npm run test:e2e`)
5. Build (`npm run build`)

**Merge requirements**: All checks pass + 1 approved review

### Deployment

- **Staging**: Auto-deploy on merge to `develop` → https://staging-dashboard.example.com
- **Production**: Auto-deploy on merge to `main` → https://dashboard.example.com

## Environment Variables

```bash
# Required
VITE_API_URL=https://api.example.com      # Backend API URL
VITE_AUTH0_DOMAIN=example.auth0.com       # Auth0 domain
VITE_AUTH0_CLIENT_ID=your-client-id       # Auth0 client ID

# Optional
VITE_ENABLE_ANALYTICS=true                # Enable analytics
VITE_LOG_LEVEL=debug                      # Log level (debug/info/warn/error)
```

## Branch Strategy

- `main` - Production (protected)
- `develop` - Integration
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Production hotfixes

**Git Workflow**: Feature branch → PR to `develop` → PR to `main`

## Code Quality Standards

- **Test Coverage**: Minimum 95%
- **TypeScript**: Strict mode enabled
- **Linting**: ESLint with Airbnb config
- **Formatting**: Prettier (auto-format on save)
```

---

## Example 2: Node.js API Server

```markdown
# Payment Processing API

RESTful API for processing payments, subscriptions, and invoices.

**Tech Stack**: Node.js 20, Express, TypeScript, PostgreSQL, Redis, Stripe

## Quick Start

Prerequisites:
- `node` >= 20.0.0
- `docker` and `docker-compose`
- `npm` >= 10.0.0

```bash
npm install
cp .env.example .env              # Configure environment
docker-compose up -d              # Start PostgreSQL + Redis
npm run db:migrate                # Run migrations
npm run db:seed                   # Seed test data
npm run dev                       # Start at http://localhost:3000
```

Verify: `curl http://localhost:3000/health` should return `{"status":"ok"}`

## Common Commands

### Development
- `npm run dev` - Start with hot reload
- `npm run dev:debug` - Start with debugger (port 9229)

### Testing (TDD Required)
- `npm test` - Run all tests (Jest)
- `npm test -- --watch` - Watch mode for TDD
- `npm run test:integration` - Integration tests only
- `npm run test:e2e` - E2E API tests
- `npm run test:coverage` - Coverage report (target: 95%+)

### Database
- `npm run db:migrate` - Run migrations
- `npm run db:migrate:rollback` - Rollback last migration
- `npm run db:seed` - Seed database
- `npm run db:reset` - Reset (destructive!)

### Code Quality
- `npm run lint` - ESLint
- `npm run type-check` - TypeScript check
- `npm run format` - Prettier

### Build
- `npm run build` - Compile TypeScript
- `npm start` - Run production build

## Project Structure

```
src/
├── api/
│   ├── routes/           # Express route handlers
│   ├── middlewares/      # Express middlewares
│   └── validators/       # Request validation (Joi)
├── services/             # Business logic
│   ├── payment/         # Payment processing
│   ├── subscription/    # Subscription management
│   └── invoice/         # Invoice generation
├── models/              # Database models (Prisma)
├── utils/               # Utilities
├── types/               # TypeScript types
└── config/              # Configuration

tests/
├── unit/               # Unit tests
├── integration/        # Integration tests
└── e2e/               # E2E API tests
```

## Development Workflow (TDD)

### 1. Write Test First

```bash
touch tests/unit/services/payment/processPayment.test.ts
npm test -- --watch tests/unit/services/payment/processPayment.test.ts
```

### 2. Implement Service

```typescript
// src/services/payment/processPayment.ts
export async function processPayment(params: PaymentParams) {
  // Implementation
}
```

### 3. Integration Test

```bash
npm run test:integration
```

### 4. E2E API Test

```bash
npm run test:e2e
```

## API Documentation

- **Local**: http://localhost:3000/api-docs (Swagger UI)
- **Staging**: https://api-staging.example.com/api-docs
- **Production**: https://api.example.com/api-docs

## Environment Variables

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/payment_db

# Redis
REDIS_URL=redis://localhost:6379

# Stripe
STRIPE_SECRET_KEY=sk_test_xxx                # Get from Stripe dashboard
STRIPE_WEBHOOK_SECRET=whsec_xxx              # Webhook signing secret

# Auth
JWT_SECRET=your-secret-key-here              # Generate: openssl rand -base64 32

# Optional
NODE_ENV=development                         # development/production
PORT=3000                                    # Server port
LOG_LEVEL=debug                              # debug/info/warn/error
```

## CI/CD

### GitHub Actions

Every PR:
1. Lint + Type check
2. Unit tests
3. Integration tests (with PostgreSQL service)
4. E2E tests
5. Build verification

### Deployment

- **Staging**: Auto-deploy on merge to `develop`
- **Production**: Auto-deploy on merge to `main` (requires manual approval)

Deployment platform: Railway

## Security

- All endpoints require JWT authentication (except `/health`, `/docs`)
- Rate limiting: 100 req/min per IP
- Request validation with Joi
- SQL injection prevention: Parameterized queries (Prisma)
- XSS prevention: Helmet.js middleware

## Troubleshooting

**Database connection fails**:
```bash
docker-compose ps      # Ensure PostgreSQL is running
npm run db:migrate     # Ensure migrations are applied
```

**Tests fail with "port already in use"**:
```bash
lsof -ti:3000 | xargs kill  # Kill process on port 3000
```
```

---

## Example 3: Python CLI Tool

```markdown
# Data Migration Tool

CLI tool for migrating data between databases (PostgreSQL, MySQL, MongoDB).

**Tech Stack**: Python 3.11, Click, SQLAlchemy, PyMongo

## Quick Start

Prerequisites:
- `python` >= 3.11
- `uv` package manager (install: `pip install uv`)

```bash
uv venv                    # Create virtual environment
source .venv/bin/activate  # Activate (Windows: .venv\Scripts\activate)
uv pip install -e ".[dev]" # Install with dev dependencies
dm --help                  # Verify installation
```

## Common Commands

### Installation
- `uv pip install -e .` - Install in development mode
- `uv pip install -e ".[dev]"` - Install with dev dependencies

### Testing (TDD Required)
- `pytest` - Run all tests
- `pytest --watch` - Watch mode for TDD (requires pytest-watch)
- `pytest --cov` - Coverage report (target: 95%+)
- `pytest -v tests/test_postgres.py` - Run specific test

### Code Quality
- `ruff check .` - Lint with Ruff
- `ruff check --fix .` - Auto-fix issues
- `mypy src/` - Type checking
- `black src/ tests/` - Format code

### Usage
- `dm migrate --source postgres://... --dest mysql://...` - Migrate data
- `dm validate --source postgres://...` - Validate source
- `dm --version` - Show version

## Project Structure

```
src/data_migrator/
├── cli/              # Click command definitions
├── connectors/       # Database connectors
│   ├── postgres.py
│   ├── mysql.py
│   └── mongodb.py
├── transformers/     # Data transformers
├── validators/       # Data validators
└── utils/           # Utilities

tests/
├── unit/            # Unit tests
├── integration/     # Integration tests (requires Docker)
└── fixtures/        # Test fixtures
```

## Development Workflow (TDD)

### 1. Write Test First

```bash
touch tests/unit/test_postgres_connector.py
pytest --watch tests/unit/test_postgres_connector.py
```

Example test:
```python
import pytest
from data_migrator.connectors.postgres import PostgresConnector

def test_connect_to_postgres():
    connector = PostgresConnector("postgresql://localhost/test")
    assert connector.is_connected()
```

### 2. Implement Feature

```python
# src/data_migrator/connectors/postgres.py
class PostgresConnector:
    def is_connected(self):
        # Implementation
        pass
```

### 3. Verify Coverage

```bash
pytest --cov --cov-report=term-missing
# Ensure 95%+ coverage
```

### 4. Integration Test

```bash
docker-compose up -d postgres  # Start PostgreSQL for testing
pytest tests/integration/
```

## Environment Variables

```bash
# Optional
LOG_LEVEL=DEBUG              # Logging level (DEBUG/INFO/WARNING/ERROR)
DB_TIMEOUT=30               # Database connection timeout (seconds)
```

## CI/CD

### GitHub Actions

Every PR:
1. Lint (Ruff)
2. Type check (mypy)
3. Unit tests
4. Integration tests (with Docker services)
5. Coverage check (minimum 95%)

### Publishing

New version on tag push:
```bash
git tag v1.2.3
git push origin v1.2.3
# GitHub Actions auto-publishes to PyPI
```

## Installation for Users

```bash
pip install data-migrator
dm --help
```

## Code Quality Standards

- **Test Coverage**: Minimum 95%
- **Type Hints**: Required for all functions
- **Linting**: Ruff
- **Formatting**: Black
- **Docstrings**: Google style
```

---

## Example 4: Library/Package (npm)

```markdown
# React Form Validator

Lightweight form validation library for React with TypeScript support.

**Tech Stack**: React 18, TypeScript, Vite (for build), Vitest

## Quick Start (Development)

Prerequisites:
- `node` >= 18
- `npm` >= 9

```bash
npm install
npm run dev         # Start playground at http://localhost:5173
npm test -- --watch # Run tests in watch mode
```

## Common Commands

### Development
- `npm run dev` - Start playground for testing
- `npm run build` - Build library (dist/)
- `npm run build:watch` - Build in watch mode

### Testing (TDD Required)
- `npm test` - Run tests
- `npm test -- --watch` - Watch mode for TDD
- `npm run test:coverage` - Coverage (target: 95%+)

### Code Quality
- `npm run lint` - ESLint
- `npm run type-check` - TypeScript check
- `npm run format` - Prettier

### Release
- `npm run changeset` - Create changeset
- `npm run version` - Bump version
- `npm run release` - Publish to npm (CI only)

## Project Structure

```
src/
├── validators/      # Validation functions
├── hooks/          # React hooks
├── utils/          # Utilities
├── types/          # TypeScript types
└── index.ts        # Public API

playground/         # Development playground
tests/             # Tests
dist/              # Build output (gitignored)
```

## Development Workflow (TDD)

### 1. Write Test First

```bash
touch tests/validators/email.test.ts
npm test -- --watch tests/validators/email.test.ts
```

### 2. Implement Validator

```typescript
// src/validators/email.ts
export function validateEmail(value: string): boolean {
  // Implementation
}
```

### 3. Test in Playground

```typescript
// playground/App.tsx
import { validateEmail } from '../src'

function App() {
  // Test the new validator
}
```

### 4. Update Public API

```typescript
// src/index.ts
export { validateEmail } from './validators/email'
```

### 5. Verify Build

```bash
npm run build
npm pack  # Test package creation
```

## Publishing Workflow

1. Create feature, write tests, implement
2. Update docs in README.md
3. Create changeset:
   ```bash
   npm run changeset
   ```
4. Commit and PR to `main`
5. On merge, GitHub Actions auto-publishes to npm

## Code Quality Standards

- **Test Coverage**: Minimum 95%
- **TypeScript**: Strict mode
- **Bundle Size**: Keep under 5KB gzipped
- **No Dependencies**: Zero runtime dependencies

## For Users

### Installation

```bash
npm install react-form-validator
```

### Usage

```typescript
import { validateEmail, useFormValidator } from 'react-form-validator'

function MyForm() {
  const { validate, errors } = useFormValidator({
    email: [validateEmail]
  })

  // Use validator
}
```

See full documentation: https://react-form-validator.dev
```

---

## Key Takeaways from Examples

### Common Patterns

1. **Quick Start section is always first** - Get developers running ASAP
2. **TDD workflow is explicit** - Step-by-step instructions
3. **Commands are concrete** - No "run the tests", always specific commands
4. **File paths are accurate** - Exact directory structure
5. **Environment variables are documented** - With examples and instructions
6. **CI/CD is described** - What runs on PR, what deploys where

### Project-Specific Variations

- **Web apps** emphasize dev server, E2E tests, deployment URLs
- **APIs** emphasize database setup, API docs, authentication
- **CLI tools** emphasize installation, usage examples, PyPI/npm publishing
- **Libraries** emphasize playground, build output, bundle size, publishing

### Consistency Across All Examples

- Prerequisites with version numbers
- Test coverage requirements (95%+)
- Code quality tools (linters, formatters, type checkers)
- Git workflow and branch strategy
- CI/CD pipeline documentation
