# CLAUDE.md Best Practices

This document provides comprehensive best practices for creating effective CLAUDE.md files.

## Core Principles

### 1. Specificity Over Generality

**❌ Bad**:
```markdown
## Setup

Install dependencies and run the project.
```

**✅ Good**:
```markdown
## Setup

```bash
npm install
npm run dev
```

The development server will start at http://localhost:3000
```

**Why**: Concrete commands are immediately actionable. Claude can execute them without guessing.

### 2. Actual File/Directory References

**❌ Bad**:
```markdown
Tests are in the test directory.
```

**✅ Good**:
```markdown
Tests are organized as follows:
- `tests/unit/` - Unit tests
- `tests/integration/` - Integration tests
- `tests/e2e/` - End-to-end tests with Playwright
```

**Why**: Specific paths help Claude navigate your codebase efficiently.

### 3. Consistency in Terminology

**❌ Bad**:
```markdown
## Building
Run the build command.

## Deployment
Execute the compilation step before deploying.
```

**✅ Good**:
```markdown
## Building
```bash
npm run build
```

## Deployment
After building with `npm run build`, deploy to production:
```bash
npm run deploy
```
```

**Why**: Consistent terminology prevents confusion.

### 4. Workflow Over Theory

**❌ Bad**:
```markdown
We use Test-Driven Development (TDD). TDD is a software development process...
```

**✅ Good**:
```markdown
## Development Workflow (TDD)

1. Write a failing test first:
   ```bash
   npm test -- --watch src/components/Button.test.tsx
   ```

2. Implement the minimum code to pass the test

3. Refactor while keeping tests green

4. Commit with conventional commit message:
   ```bash
   git commit -m "feat(Button): add click handler"
   ```
```

**Why**: Practical workflows are more valuable than theoretical explanations.

### 5. Tool Versions and Prerequisites

**❌ Bad**:
```markdown
## Requirements
- Node.js
- Docker
```

**✅ Good**:
```markdown
## Prerequisites

Required tools (must be in `$PATH`):
- `node` >= 18.0.0 (check: `node --version`)
- `npm` >= 9.0.0 (check: `npm --version`)
- `docker` >= 24.0.0 (check: `docker --version`)

Optional for enhanced development:
- `docker-compose` >= 2.20.0
```

**Why**: Version requirements prevent compatibility issues.

## Section Guidelines

### Essential Sections

Every CLAUDE.md should include:

1. **Project Overview** (3-5 sentences)
   - What the project does
   - Primary technology stack
   - Target audience/use case

2. **Setup Instructions**
   - Prerequisites with version requirements
   - Installation steps
   - Verification commands

3. **Development Workflow**
   - How to start development environment
   - Testing strategy (TDD/E2E)
   - Code quality tools (linters, formatters)

4. **Project Structure**
   - Key directories and their purposes
   - Important file locations

5. **Common Commands**
   - Frequently used commands with examples

### Optional but Recommended Sections

- **Architecture** - For complex projects
- **Deployment** - If deployment process is non-trivial
- **Troubleshooting** - Common issues and solutions
- **Contributing** - For open-source projects
- **API Documentation** - For libraries/APIs

## Content Quality Standards

### Use Imperative Mood for Instructions

**❌ Bad**: "You should run tests"
**✅ Good**: "Run tests with `npm test`"

### Provide Context for Non-Obvious Decisions

**❌ Bad**:
```markdown
Don't modify `src/core/`.
```

**✅ Good**:
```markdown
Don't modify `src/core/` - This directory contains auto-generated code from the GraphQL schema. Regenerate with `npm run codegen` instead.
```

### Include Expected Outcomes

**❌ Bad**:
```bash
npm run build
```

**✅ Good**:
```bash
npm run build
# Output: Built files will be in dist/
# Expected: ~2-3 seconds for incremental builds
```

### Update Regularly

**❌ Bad**: Stale CLAUDE.md with outdated commands
**✅ Good**: Update CLAUDE.md whenever you:
- Add new dependencies
- Change project structure
- Modify build/test processes
- Add new environment variables

## Anti-Patterns to Avoid

### 1. Don't Duplicate README.md

CLAUDE.md is for **AI development assistants**, not end users.

**README.md**: Marketing, features, public documentation
**CLAUDE.md**: Development workflows, file structure, coding standards

### 2. Don't Include Sensitive Information

**❌ Never include**:
- API keys
- Passwords
- Private URLs
- Credentials

**✅ Instead**:
```markdown
## Environment Variables

Required in `.env` (not committed to git):
- `DATABASE_URL` - PostgreSQL connection string
- `API_KEY` - Service API key (get from dashboard)
```

### 3. Don't Use Vague Language

**❌ Avoid**:
- "Usually"
- "Might need to"
- "Sometimes"
- "Probably"

**✅ Use**:
- Specific commands
- Concrete paths
- Exact version numbers
- Definitive statements

### 4. Don't Overwhelm with Too Much Detail

**❌ Bad**: 500-line explanation of architecture
**✅ Good**: 50-line overview with links to detailed docs

Balance depth with readability. Use `references/` for detailed documentation.

## Template Selection Guide

Choose the right template based on project type:

- **frontend.md** - React/Vue/Angular single-page apps
- **backend-api.md** - REST/GraphQL APIs
- **pub-sub.md** - Event-driven systems (Kafka, RabbitMQ)
- **proxy.md** - API Gateways, reverse proxies
- **batch.md** - Cron jobs, data pipelines
- **library.md** - npm packages, Python packages
- **cli-tool.md** - Command-line applications
- **other.md** - None of the above

## Quality Checklist

Before finalizing CLAUDE.md, verify:

- [ ] All commands are copy-paste executable
- [ ] File paths are accurate
- [ ] Version numbers are current
- [ ] No TODO markers remain
- [ ] Tested on a clean machine (if possible)
- [ ] Covers TDD workflow if applicable
- [ ] Includes E2E testing strategy if applicable
- [ ] CI/CD pipeline documented
- [ ] Branch strategy explained
- [ ] Code quality tools listed (linters, formatters)

Run `check_claude_md.py` for automated validation:

```bash
python scripts/check_claude_md.py CLAUDE.md
```

## Examples of Great CLAUDE.md Files

See `references/examples.md` for real-world examples from various project types.
