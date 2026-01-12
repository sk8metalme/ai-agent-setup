# Project Structure Patterns

This guide explains how to document project structure effectively in CLAUDE.md.

## Why Document Structure?

A well-documented project structure helps developers:
- Find files quickly
- Understand architectural decisions
- Know where to add new features
- Follow project conventions

## Basic Structure Documentation

### Simple Directory Tree

```markdown
## Project Structure

```
project-root/
├── src/                  # Source code
│   ├── components/      # React components
│   ├── services/        # Business logic
│   ├── utils/           # Utility functions
│   └── types/           # TypeScript types
├── tests/               # Test files
├── public/              # Static assets
├── docs/                # Documentation
└── scripts/             # Build/deployment scripts
```

**Key Files**:
- `src/index.tsx` - Application entry point
- `src/App.tsx` - Root component
- `vite.config.ts` - Build configuration
```

### Detailed Structure with Descriptions

```markdown
## Project Structure

```
src/
├── components/               # React components
│   ├── ui/                  # Base UI components (Button, Input, etc.)
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx
│   │   └── index.ts
│   └── features/            # Feature-specific components
│       └── UserProfile/     # One directory per component
│           ├── UserProfile.tsx
│           ├── UserProfile.test.tsx
│           ├── UserProfile.styles.ts
│           └── index.ts
├── hooks/                   # Custom React hooks
│   ├── useAuth.ts          # Authentication hook
│   └── useDebounce.ts      # Debounce hook
├── services/                # External service integrations
│   ├── api/                # API client
│   │   ├── client.ts       # Axios/Fetch configuration
│   │   ├── auth.ts         # Authentication endpoints
│   │   └── users.ts        # User endpoints
│   └── analytics/          # Analytics integration
├── stores/                  # State management (Zustand/Redux)
│   ├── authStore.ts        # Authentication state
│   └── userStore.ts        # User state
├── utils/                   # Utility functions
│   ├── validation.ts       # Input validation
│   ├── formatting.ts       # Date/number formatting
│   └── constants.ts        # App constants
├── types/                   # TypeScript type definitions
│   ├── api.ts              # API response types
│   └── models.ts           # Domain models
└── styles/                  # Global styles
    ├── globals.css
    └── theme.ts            # Theme configuration

tests/
├── unit/                    # Unit tests (mirrors src/)
├── integration/             # Integration tests
└── e2e/                    # End-to-end tests
    └── playwright.config.ts

public/                      # Static assets (served as-is)
├── images/
├── fonts/
└── favicon.ico
```

**Naming Conventions**:
- Components: PascalCase (`UserProfile.tsx`)
- Hooks: camelCase with `use` prefix (`useAuth.ts`)
- Utilities: camelCase (`validation.ts`)
- Types: PascalCase (`User.ts`, `ApiResponse.ts`)
- Constants: UPPER_SNAKE_CASE or camelCase
```

## Structure Patterns by Project Type

### Frontend (React/Vue)

```markdown
## Frontend Project Structure

```
src/
├── app/                    # Next.js App Router (if using Next.js)
│   ├── layout.tsx
│   ├── page.tsx
│   └── (routes)/          # Route groups
├── components/            # Reusable components
│   ├── ui/               # Design system components
│   └── features/         # Feature-specific components
├── hooks/                # Custom hooks
├── lib/                  # Third-party integrations
│   ├── supabase.ts      # Supabase client
│   └── stripe.ts        # Stripe integration
├── stores/               # State management
├── styles/               # Global styles
└── types/                # TypeScript types

public/
└── assets/               # Images, fonts, etc.
```

**Component Co-location**:
Each component has its own directory:
```
components/features/ProductCard/
├── ProductCard.tsx          # Main component
├── ProductCard.test.tsx     # Tests
├── ProductCard.stories.tsx  # Storybook stories
├── ProductCard.styles.ts    # Styles (CSS-in-JS)
└── index.ts                 # Public API
```
```

### Backend API (Node.js/Express)

```markdown
## Backend API Structure

```
src/
├── api/                   # API layer
│   ├── routes/           # Route definitions
│   │   ├── index.ts      # Route registry
│   │   ├── auth.ts       # Authentication routes
│   │   └── users.ts      # User routes
│   ├── middlewares/      # Express middlewares
│   │   ├── auth.ts       # Authentication middleware
│   │   ├── errorHandler.ts
│   │   └── validation.ts
│   └── validators/       # Request validation schemas (Joi/Zod)
├── services/             # Business logic
│   ├── auth/
│   │   ├── authService.ts
│   │   └── authService.test.ts
│   └── users/
│       ├── userService.ts
│       └── userService.test.ts
├── models/               # Database models (Prisma/TypeORM)
│   ├── User.ts
│   └── Post.ts
├── database/             # Database configuration
│   ├── client.ts         # Database client
│   └── migrations/       # Migration files
├── utils/                # Utilities
│   ├── logger.ts         # Winston logger
│   └── errors.ts         # Custom error classes
├── config/               # Configuration
│   ├── database.ts
│   ├── auth.ts
│   └── index.ts
└── types/                # TypeScript types

tests/
├── unit/                 # Unit tests
├── integration/          # Integration tests
└── e2e/                  # API E2E tests

scripts/
├── seed.ts              # Database seeding
└── migrate.ts           # Migration runner
```

**Layered Architecture**:
```
Request → Route → Middleware → Validator → Service → Model → Database
                                              ↓
Response ← Route ← Middleware ← Service ← Model ← Database
```
```

### Monorepo (Nx/Turborepo)

```markdown
## Monorepo Structure

```
packages/
├── web/                  # Frontend application
│   ├── src/
│   ├── public/
│   └── package.json
├── api/                  # Backend API
│   ├── src/
│   ├── prisma/
│   └── package.json
├── mobile/               # React Native app
│   ├── src/
│   └── package.json
├── shared/               # Shared code
│   ├── types/           # Shared TypeScript types
│   ├── utils/           # Shared utilities
│   └── package.json
└── ui/                   # Shared UI components
    ├── src/
    └── package.json

apps/                     # Alternative naming (Nx style)
libs/                     # Alternative naming (Nx style)

tools/                    # Build tools and scripts
├── generators/          # Code generators
└── scripts/             # Automation scripts

.github/
└── workflows/           # CI/CD workflows
```

**Package Dependencies**:
- `web` depends on `shared`, `ui`
- `api` depends on `shared`
- `mobile` depends on `shared`, `ui`
- `ui` depends on `shared`
```

### Python (FastAPI/Django)

```markdown
## Python Project Structure

```
src/
├── app/                  # FastAPI application
│   ├── api/             # API routes
│   │   ├── v1/         # API version 1
│   │   │   ├── auth.py
│   │   │   └── users.py
│   │   └── deps.py     # Dependencies (DB session, etc.)
│   ├── core/            # Core functionality
│   │   ├── config.py   # Settings (Pydantic)
│   │   ├── security.py # Auth/JWT
│   │   └── database.py # Database connection
│   ├── models/          # SQLAlchemy models
│   │   ├── user.py
│   │   └── post.py
│   ├── schemas/         # Pydantic schemas
│   │   ├── user.py
│   │   └── post.py
│   ├── services/        # Business logic
│   │   ├── auth_service.py
│   │   └── user_service.py
│   └── main.py          # FastAPI app entry

tests/
├── unit/                # Unit tests (pytest)
├── integration/         # Integration tests
└── conftest.py          # Pytest fixtures

alembic/                 # Database migrations
├── versions/
└── env.py

scripts/                 # Utility scripts
├── seed.py
└── migrate.py
```

**Import Paths**:
Use absolute imports from `src`:
```python
from app.models.user import User
from app.services.auth_service import AuthService
```
```

### CLI Tool

```markdown
## CLI Tool Structure

```
src/myapp/
├── cli/                  # Click commands
│   ├── __init__.py
│   ├── main.py          # Main command group
│   ├── migrate.py       # Migrate subcommand
│   └── validate.py      # Validate subcommand
├── core/                 # Core functionality
│   ├── connectors/      # Database connectors
│   │   ├── postgres.py
│   │   └── mysql.py
│   ├── transformers/    # Data transformers
│   └── validators/      # Data validators
├── utils/                # Utilities
│   ├── logger.py
│   └── config.py
└── __main__.py           # Entry point (python -m myapp)

tests/
├── unit/
└── integration/

docs/                     # Documentation
└── commands/            # Command documentation
```

**Entry Point**:
```python
# src/myapp/__main__.py
from myapp.cli.main import cli

if __name__ == '__main__':
    cli()
```

**Usage**:
```bash
myapp migrate --source postgres://... --dest mysql://...
myapp validate --source postgres://...
```
```

## Key Files to Document

### Configuration Files

```markdown
## Key Configuration Files

- `.env.example` - Environment variable template
- `package.json` - Dependencies and scripts (Node.js)
- `pyproject.toml` - Project metadata and dependencies (Python)
- `tsconfig.json` - TypeScript compiler options
- `vite.config.ts` / `next.config.js` - Build configuration
- `.eslintrc.js` - Linting rules
- `.prettierrc` - Code formatting rules
- `jest.config.js` / `vitest.config.ts` - Test configuration
- `playwright.config.ts` - E2E test configuration
- `docker-compose.yml` - Docker services
- `.github/workflows/` - CI/CD pipelines
```

### Entry Points

```markdown
## Application Entry Points

**Frontend**:
- `src/index.tsx` - React entry point
- `src/main.tsx` - Vite/React entry point
- `src/app/layout.tsx` - Next.js root layout

**Backend**:
- `src/index.ts` - Express server entry
- `src/main.py` - FastAPI entry
- `src/server.ts` - Node.js server

**CLI**:
- `src/cli.ts` - CLI entry point
- `src/__main__.py` - Python CLI entry
```

## File Naming Conventions

### Component Files

```markdown
## File Naming Conventions

### React Components

- **Component**: `UserProfile.tsx` (PascalCase)
- **Test**: `UserProfile.test.tsx`
- **Stories**: `UserProfile.stories.tsx`
- **Styles**: `UserProfile.styles.ts` or `UserProfile.module.css`

### Hooks

- `useAuth.ts` (camelCase with `use` prefix)
- `useDebounce.ts`
- `useLocalStorage.ts`

### Utilities

- `validation.ts` (camelCase)
- `formatting.ts`
- `api-client.ts` (kebab-case for multi-word)

### Types

- `User.ts` (PascalCase)
- `ApiResponse.ts`
- `index.ts` (re-exports)

### Constants

- `constants.ts` (camelCase file)
- `API_ENDPOINTS.ts` (UPPER_SNAKE_CASE if entire file is constants)
```

## Co-location Strategies

### Component Co-location

```markdown
## Component Co-location

**Option 1: Flat Structure**
```
components/
├── Button.tsx
├── Button.test.tsx
├── Input.tsx
└── Input.test.tsx
```

**Option 2: Folder per Component** (Recommended)
```
components/
├── Button/
│   ├── Button.tsx
│   ├── Button.test.tsx
│   ├── Button.stories.tsx
│   └── index.ts        # export { Button } from './Button'
└── Input/
    ├── Input.tsx
    ├── Input.test.tsx
    └── index.ts
```

**Benefits of Option 2**:
- Related files grouped together
- Easy to move/delete entire feature
- Clear component boundaries
- Supports more files per component (styles, utils, etc.)
```

### Test Co-location

```markdown
## Test File Placement

**Option 1: Co-located** (Recommended for unit tests)
```
src/
├── utils/
│   ├── validation.ts
│   └── validation.test.ts
└── components/
    └── Button/
        ├── Button.tsx
        └── Button.test.tsx
```

**Option 2: Separate test directory** (For E2E/integration)
```
tests/
├── unit/           # Mirrors src/ structure
│   └── utils/
│       └── validation.test.ts
├── integration/
└── e2e/
```

**Hybrid Approach** (Best practice):
- Unit tests: Co-located with source
- Integration tests: Separate `tests/integration/`
- E2E tests: Separate `tests/e2e/`
```

## Migration Patterns

### Adding New Structure

```markdown
## Migrating Project Structure

When introducing new structure patterns:

1. **Document the change** in CLAUDE.md
2. **Create example** in new structure
3. **Gradually migrate** existing code
4. **Update linting rules** to enforce new structure

Example:
```markdown
## Project Structure Updates (2024-03-15)

We're migrating from flat component structure to folder-per-component.

**Old**:
```
components/
├── Button.tsx
└── Button.test.tsx
```

**New**:
```
components/
└── Button/
    ├── Button.tsx
    ├── Button.test.tsx
    └── index.ts
```

**Migration Status**: 15/50 components migrated

**TODO**: Migrate remaining components in `components/legacy/`
```
```

## Best Practices

1. **Be Specific**: Show actual directory names, not placeholders
2. **Explain Choices**: Document why structure is organized this way
3. **Show Key Files**: Highlight important entry points and configs
4. **Use ASCII Trees**: Visual directory trees are easier to scan
5. **Keep Updated**: Update structure docs when making changes
6. **Naming Consistency**: Document and enforce naming conventions
7. **Co-locate Related Files**: Keep tests, styles, and components together
