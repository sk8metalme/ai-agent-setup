# CLAUDE.md Structure Design Guide

This guide explains how to structure your CLAUDE.md for maximum effectiveness.

## Document Structure Patterns

Choose the structure that best fits your project's needs:

### Pattern 1: Command-First (Recommended for Most Projects)

Best for projects where developers need quick access to common commands.

```markdown
# Project Name

## Quick Start

```bash
npm install
npm run dev
```

## Common Commands

- `npm test` - Run tests
- `npm run build` - Build for production
- `npm run lint` - Check code quality

## Project Structure

...

## Development Workflow

...

## Architecture

...
```

**Use when**: Developers frequently run commands (web apps, APIs, CLIs)

### Pattern 2: Architecture-First

Best for complex projects where understanding architecture is critical.

```markdown
# Project Name

## Architecture Overview

[High-level architecture diagram or description]

## Core Components

### Frontend (React + TypeScript)
- `src/components/` - React components
- `src/hooks/` - Custom hooks
- `src/stores/` - State management (Zustand)

### Backend (Node.js + Express)
- `api/routes/` - API endpoints
- `api/services/` - Business logic
- `api/models/` - Database models

## Development Workflow

...

## Common Commands

...
```

**Use when**: Architecture complexity is high (microservices, multi-tier systems)

### Pattern 3: Workflow-First

Best for projects with strict development processes (e.g., TDD-first, compliance-heavy).

```markdown
# Project Name

## Development Workflow

### 1. Feature Development (TDD)

1. Create feature branch:
   ```bash
   git checkout -b feature/user-authentication
   ```

2. Write failing test first:
   ```bash
   npm test -- --watch src/auth/login.test.ts
   ```

3. Implement feature to pass test

4. Run full test suite:
   ```bash
   npm test
   ```

5. Create PR when all tests pass

### 2. Code Review Process

...

### 3. Deployment

...

## Project Structure

...
```

**Use when**: Development process is more important than individual commands

## Section Ordering Principles

### Progressive Disclosure

Order sections from **immediate needs** to **deep understanding**:

1. **Quick Start** - Get running in < 5 minutes
2. **Common Commands** - Daily development tasks
3. **Project Structure** - Navigate the codebase
4. **Development Workflow** - Deeper process understanding
5. **Architecture** - System design details
6. **Advanced Topics** - Edge cases, optimization

### Frequency of Use

Place most frequently accessed sections first:

**High Frequency**:
- Quick Start
- Common Commands
- Testing
- Environment Setup

**Medium Frequency**:
- Project Structure
- Development Workflow
- Deployment

**Low Frequency**:
- Architecture Deep Dives
- Historical Decisions
- Troubleshooting

## Essential Sections Breakdown

### 1. Project Overview (Required)

**Purpose**: Quickly understand what the project does

**Length**: 3-5 sentences

**Structure**:
```markdown
# Project Name

Brief description of what this project does (1 sentence).

Primary use case or target audience (1 sentence).

Key technology stack: TypeScript, React, Node.js, PostgreSQL.

[Optional: Link to main documentation if this is internal tooling]
```

### 2. Quick Start (Required)

**Purpose**: Get development environment running ASAP

**Length**: < 10 commands

**Structure**:
```markdown
## Quick Start

Prerequisites:
- Node.js >= 18 (`node --version`)
- Docker Desktop running

```bash
git clone <repo-url>
cd project-name
npm install
cp .env.example .env  # Edit .env with your values
docker-compose up -d  # Start database
npm run dev           # Start dev server
```

Visit http://localhost:3000
```

### 3. Common Commands (Required)

**Purpose**: Reference for daily development tasks

**Structure**:
```markdown
## Common Commands

### Development
- `npm run dev` - Start development server (http://localhost:3000)
- `npm run dev:debug` - Start with debugger attached (port 9229)

### Testing
- `npm test` - Run all tests
- `npm test -- --watch` - Run tests in watch mode
- `npm run test:e2e` - Run E2E tests (requires dev server running)
- `npm run test:coverage` - Generate coverage report (target: 95%+)

### Code Quality
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Auto-fix linting issues
- `npm run type-check` - Run TypeScript compiler

### Building
- `npm run build` - Build for production
- `npm run build:analyze` - Analyze bundle size

### Database
- `npm run db:migrate` - Run migrations
- `npm run db:seed` - Seed database
- `npm run db:reset` - Reset database (destructive!)
```

### 4. Project Structure (Required)

**Purpose**: Navigate codebase efficiently

**Structure**:
```markdown
## Project Structure

```
project/
├── src/
│   ├── components/     # React components (presentational)
│   ├── containers/     # Container components (connected to state)
│   ├── hooks/          # Custom React hooks
│   ├── services/       # API calls and business logic
│   ├── utils/          # Utility functions
│   ├── types/          # TypeScript type definitions
│   └── __tests__/      # Unit tests (co-located with source)
├── tests/
│   ├── e2e/           # Playwright E2E tests
│   └── integration/   # Integration tests
├── public/            # Static assets
├── docs/              # Additional documentation
└── scripts/           # Build/deployment scripts
```

**Key Files**:
- `src/index.tsx` - Application entry point
- `src/App.tsx` - Root component
- `vite.config.ts` - Build configuration
- `.env.example` - Environment variable template
```

### 5. Development Workflow (Strongly Recommended)

**Purpose**: Explain how to contribute code

**Structure**:
```markdown
## Development Workflow

### TDD Approach (Required)

1. **Write Test First**
   ```bash
   # Create test file
   touch src/features/auth/login.test.ts

   # Run in watch mode
   npm test -- --watch src/features/auth/login.test.ts
   ```

2. **Implement Feature** (minimum code to pass test)

3. **Refactor** (keep tests green)

4. **Verify Coverage**
   ```bash
   npm run test:coverage
   # Ensure new code has 95%+ coverage
   ```

### E2E Testing

Run E2E tests before creating PR:

```bash
npm run dev &           # Start dev server in background
npm run test:e2e        # Run E2E tests
npm run test:e2e:ui     # Run with Playwright UI
```

### Branch Strategy

- `main` - Production (protected, requires PR + review)
- `develop` - Integration branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Production hotfixes

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/user-profile

# Make changes, write tests

# Commit with conventional commit format
git commit -m "feat(profile): add user profile page

- Add ProfilePage component
- Add profile API integration
- Add unit and E2E tests

Closes #123"

# Push and create PR
git push -u origin feature/user-profile
gh pr create --title "feat: Add user profile page" --body "Description here"
```
```

### 6. CI/CD (If Applicable)

**Purpose**: Explain automated checks and deployment

**Structure**:
```markdown
## CI/CD

### GitHub Actions Workflow

On every PR:
1. Lint check (`npm run lint`)
2. Type check (`npm run type-check`)
3. Unit tests (`npm test`)
4. E2E tests (`npm run test:e2e`)
5. Build verification (`npm run build`)

All checks must pass before merge.

### Deployment

**Staging**: Auto-deploy on merge to `develop`
- URL: https://staging.example.com
- Deployed via Vercel

**Production**: Auto-deploy on merge to `main`
- URL: https://example.com
- Deployed via Vercel
- Requires: All tests pass + 1 approved review
```

### 7. Environment Variables (If Applicable)

**Structure**:
```markdown
## Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# Required
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
API_KEY=your-api-key-here                    # Get from dashboard

# Optional
DEBUG=true                                   # Enable debug logging
FEATURE_FLAG_NEW_UI=false                    # Enable new UI
```

**Security**: Never commit `.env` to git (already in `.gitignore`)
```

## Heading Hierarchy Best Practices

### Use Semantic Heading Levels

```markdown
# Project Name (H1 - only one per document)

## Section (H2 - main sections)

### Subsection (H3 - detailed breakdowns)

#### Minor Detail (H4 - use sparingly)
```

### Don't Skip Levels

**❌ Bad**:
```markdown
# Project Name
#### Installation  (skipped H2 and H3)
```

**✅ Good**:
```markdown
# Project Name
## Getting Started
### Installation
```

### Keep Headings Scannable

**❌ Bad**: `## How to Set Up Your Local Development Environment and Database`
**✅ Good**: `## Local Setup`

## Length Guidelines

### Optimal Length by Project Type

- **Simple CLI tool**: 100-200 lines
- **Web application**: 200-400 lines
- **Microservice**: 150-300 lines
- **Monorepo**: 300-600 lines (or split into multiple files)
- **Library/Package**: 100-250 lines

### When to Split Content

If CLAUDE.md exceeds 500 lines, consider:

1. **Move detailed guides to separate files**:
   ```
   docs/
   ├── development.md       # Detailed workflow
   ├── architecture.md      # System design
   ├── deployment.md        # Deployment guide
   └── troubleshooting.md   # Common issues
   ```

   Reference from CLAUDE.md:
   ```markdown
   ## Architecture

   High-level overview here (3-5 paragraphs)

   For detailed architecture documentation, see [docs/architecture.md](docs/architecture.md)
   ```

2. **Use collapsible sections** (Markdown):
   ```markdown
   <details>
   <summary>Advanced Configuration</summary>

   Detailed content here...

   </details>
   ```

## Maintenance Strategy

### Keep CLAUDE.md Up-to-Date

**Add to PR checklist**:
- [ ] If you added a new dependency, update Prerequisites
- [ ] If you changed project structure, update Project Structure section
- [ ] If you added environment variables, update Environment Variables
- [ ] If you changed build/test commands, update Common Commands

### Review Quarterly

Every 3 months, review and update:
- [ ] Version requirements
- [ ] Deprecated dependencies
- [ ] Outdated commands
- [ ] Dead links
- [ ] Stale troubleshooting advice

Run `scripts/check_claude_md.py` to catch structural issues.
