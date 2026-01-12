# [Library Name]

[Brief 1-2 sentence description of what this library does]

**Language**: TypeScript
**Package Manager**: npm

> **Note**: This template is TypeScript/npm-specific. For other languages (Python/Go/Rust/PHP/Java/Perl), refer to language-specific templates or adapt the commands accordingly.

## Quick Start (Development)

Prerequisites:
- `[runtime]` >= [version]
- `[package-manager]` >= [version]

```bash
npm install                     # Install dependencies
npm run dev                     # Start playground/examples
npm test -- --watch             # Run tests in watch mode (TDD)
```

## Common Commands

### Development
- `npm run dev` - Start playground for manual testing
- `npm run build` - Build library (dist/)
- `npm run build:watch` - Build in watch mode

### Testing (TDD Required)
- `npm test` - Run tests
- `npm test -- --watch` - Watch mode for TDD
- `npm run test:coverage` - Coverage report (target: 95%+)

### Code Quality
- `npm run lint` - Run linter
- `npm run type-check` - TypeScript type check
- `npm run format` - Format code

### Documentation
- `npm run docs` - Generate API documentation
- `npm run docs:serve` - Serve docs locally

### Release
- `npm run changeset` - Create changeset for versioning
- `npm run version` - Bump version based on changesets
- `npm run release` - Publish to npm (CI only)

## Project Structure

```text
src/
├── index.ts                # Public API (exports)
├── core/                   # Core functionality
│   ├── validator.ts
│   └── validator.test.ts
├── utils/                  # Utilities
└── types/                  # TypeScript types

dist/                       # Build output (gitignored)
├── index.js
├── index.d.ts
└── index.mjs               # ES modules

playground/                 # Development playground
└── App.tsx                 # Test components/features

tests/
└── integration/            # Integration tests

docs/                       # Documentation
└── api/                    # Generated API docs
```

**Key Files**:
- `src/index.ts` - Public API surface
- `package.json` - Dependencies and scripts
- `tsconfig.json` - TypeScript configuration
- `README.md` - User-facing documentation

## Development Workflow (TDD)

### 1. Write Test First

```bash
touch src/core/feature.test.ts
npm test -- --watch src/core/feature.test.ts
```

Example test:
```typescript
import { myFunction } from './feature'

describe('myFunction', () => {
  it('performs expected behavior', () => {
    const result = myFunction('input')
    expect(result).toBe('expected')
  })

  it('handles edge cases', () => {
    expect(myFunction('')).toBe(null)
    expect(myFunction(null)).toBe(null)
  })
})
```

### 2. Implement Feature

```typescript
// src/core/feature.ts
export function myFunction(input: string): string | null {
  if (!input) return null
  return input.toUpperCase()
}
```

### 3. Update Public API

```typescript
// src/index.ts
export { myFunction } from './core/feature'
export type { MyFunctionOptions } from './types'
```

### 4. Test in Playground

```typescript
// playground/App.tsx (or playground.ts)
import { myFunction } from '../src'

console.log(myFunction('hello')) // Test the new feature
```

### 5. Verify Build

```bash
npm run build
npm pack  # Test package creation
```

### 6. Update Documentation

```bash
# Update README.md with new feature
# Generate API docs
npm run docs
```

## Public API Design

### Export Strategy

```typescript
// src/index.ts
// Export main functions
export { validate, transform } from './core/validator'

// Export types
export type {
  ValidatorOptions,
  ValidationResult,
  TransformOptions,
} from './types'

// Export constants
export { DEFAULT_OPTIONS } from './constants'
```

### Versioning

Follow Semantic Versioning:
- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features (backward compatible)
- **PATCH** (1.0.0 → 1.0.1): Bug fixes

## TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020"],
    "moduleResolution": "node",
    "declaration": true,
    "declarationMap": true,
    "outDir": "./dist",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

## Package Configuration

```json
// package.json
{
  "name": "[package-name]",
  "version": "1.0.0",
  "description": "[description]",
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    }
  },
  "files": [
    "dist"
  ],
  "keywords": [
    "keyword1",
    "keyword2"
  ],
  "sideEffects": false,
  "publishConfig": {
    "access": "public"
  }
}
```

## Testing

### Unit Tests

```typescript
// src/core/validator.test.ts
import { validate } from './validator'

describe('validate', () => {
  it('validates correct input', () => {
    expect(validate('test@example.com')).toBe(true)
  })

  it('rejects invalid input', () => {
    expect(validate('invalid')).toBe(false)
  })

  it('handles options', () => {
    expect(validate('test', { strict: false })).toBe(true)
  })
})
```

### Integration Tests

```typescript
// tests/integration/api.test.ts
import * as lib from '../../src'

describe('Public API', () => {
  it('exports all expected functions', () => {
    expect(lib.validate).toBeDefined()
    expect(lib.transform).toBeDefined()
  })

  it('works end-to-end', () => {
    const input = 'test@example.com'
    const isValid = lib.validate(input)
    const transformed = lib.transform(input)

    expect(isValid).toBe(true)
    expect(transformed).toBeDefined()
  })
})
```

## Build Configuration

### Bundle Size

Keep bundle size small:
- Target: < 5KB gzipped for core library
- No runtime dependencies (if possible)
- Tree-shakeable exports

Check bundle size:
```bash
npm run build
npm run size  # Uses size-limit or bundlesize
```

### Build Tool

Using [Vite/tsup/Rollup]:

```typescript
// vite.config.ts (example)
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    lib: {
      entry: 'src/index.ts',
      name: 'LibraryName',
      formats: ['es', 'cjs'],
      fileName: (format) => `index.${format === 'es' ? 'mjs' : 'js'}`,
    },
    rollupOptions: {
      external: ['react', 'react-dom'], // Peer dependencies
    },
  },
})
```

## Publishing Workflow

### Using Changesets

```bash
# 1. Make changes and write tests

# 2. Create changeset
npm run changeset
# Select change type: patch/minor/major
# Write summary of changes

# 3. Commit changes
git add .
git commit -m "feat: add new feature"

# 4. Create PR
gh pr create --title "feat: Add new feature"

# 5. After PR merge, CI will:
#    - Bump version
#    - Update CHANGELOG.md
#    - Publish to npm
```

### Manual Publishing

```bash
# Build and test
npm run build
npm test

# Version bump
npm version minor  # or: major, patch

# Publish
npm publish

# Push tags
git push --tags
```

## Code Quality Standards

- **Test Coverage**: Minimum 95%
- **Bundle Size**: < 5KB gzipped
- **Zero Dependencies**: Avoid runtime dependencies
- **TypeScript**: Strict mode enabled
- **Tree-shakeable**: ESM exports
- **Type Definitions**: Included (not @types package)

## Documentation

### README.md

Include:
- Installation instructions
- Quick start example
- API documentation
- Examples
- Contributing guide

### API Documentation

Generate with [TypeDoc/JSDoc]:

```bash
npm run docs
```

### Examples

Include practical examples:

```typescript
// examples/basic-usage.ts
import { validate } from '[package-name]'

const email = 'user@example.com'
const isValid = validate(email)

console.log(isValid) // true
```

## CI/CD

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm test -- --coverage
      - run: npm run build
      - run: npm run size

  publish:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run build
      - uses: changesets/action@v1
        with:
          publish: npm run release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## For Users

### Installation

```bash
npm install [package-name]
```

### Basic Usage

```typescript
import { validate } from '[package-name]'

const result = validate('test@example.com')
console.log(result) // true
```

### Advanced Usage

```typescript
import { validate, transform } from '[package-name]'

const input = 'test@example.com'

// With options
const isValid = validate(input, {
  strict: true,
  allowSpecial: false,
})

// Transform
const transformed = transform(input, {
  lowercase: true,
})
```

## Troubleshooting

**Issue**: TypeScript errors when importing

**Solution**:
- Ensure `types` field in package.json points to correct .d.ts file
- Check `tsconfig.json` has `declaration: true`

---

**Issue**: Tree-shaking not working

**Solution**:
- Ensure `sideEffects: false` in package.json
- Use named exports instead of default exports
- Build as ESM (`"module": "./dist/index.mjs"`)

---

**Issue**: Tests fail in CI but pass locally

**Solution**:
- Check Node.js version matches
- Use `npm ci` instead of `npm install` in CI
- Verify environment variables

## Best Practices

1. **Zero Dependencies**: Avoid runtime dependencies when possible
2. **Small Bundle**: Keep under 5KB gzipped
3. **Tree-shakeable**: Use ESM and named exports
4. **Type Definitions**: Include TypeScript definitions
5. **Semantic Versioning**: Follow semver strictly
6. **Changelog**: Maintain CHANGELOG.md
7. **Examples**: Provide practical usage examples
8. **Documentation**: Comprehensive README and API docs
