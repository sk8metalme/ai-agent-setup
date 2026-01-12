# [Project Name]

[Brief 1-2 sentence description of what this frontend application does]

**Tech Stack**: React [version], TypeScript, [Build Tool: Vite/Next.js/CRA], [State: Zustand/Redux/Context], [Styling: TailwindCSS/styled-components/CSS Modules]

## Quick Start

Prerequisites:
- `node` >= [version] (`node --version`)
- `npm` >= [version] (`npm --version`)

```bash
npm install
cp .env.example .env          # Configure environment variables
npm run dev                   # Start at http://localhost:[port]
```

## Common Commands

### Development
- `npm run dev` - Start development server
- `npm run dev:host` - Start with network access (`--host`)
- `npm run type-check` - TypeScript validation

### Testing (TDD Required)
- `npm test` - Run unit tests ([Jest/Vitest])
- `npm test -- --watch` - Watch mode for TDD
- `npm run test:e2e` - E2E tests ([Playwright/Cypress])
- `npm run test:coverage` - Coverage report (target: 95%+)

### Code Quality
- `npm run lint` - ESLint check
- `npm run lint:fix` - Auto-fix linting issues
- `npm run format` - Prettier formatting

### Build
- `npm run build` - Production build
- `npm run preview` - Preview production build

## Project Structure

```
src/
├── components/          # React components
│   ├── ui/             # Base components (Button, Input, etc.)
│   └── features/       # Feature-specific components
├── pages/              # Page components (for routing)
├── hooks/              # Custom React hooks
├── stores/             # State management ([Zustand/Redux])
├── services/           # API calls
├── utils/              # Utility functions
├── types/              # TypeScript types
└── styles/             # Global styles

tests/
├── unit/              # Unit tests
└── e2e/               # E2E tests

public/                 # Static assets (images, fonts, etc.)
```

**Key Files**:
- `src/main.tsx` or `src/index.tsx` - Application entry point
- `src/App.tsx` - Root component
- `[vite/next].config.ts` - Build configuration
- `.env.example` - Environment variable template

## Development Workflow (TDD)

### 1. Create Feature Branch

```bash
git checkout -b feature/[feature-name]
```

### 2. Write Test First

```bash
# Create test file
touch src/components/features/[Component].test.tsx

# Run in watch mode
npm test -- --watch src/components/features/[Component].test.tsx
```

Example test:
```typescript
import { render, screen } from '@testing-library/react'
import { Component } from './Component'

test('renders component correctly', () => {
  render(<Component />)
  expect(screen.getByText('Expected Text')).toBeInTheDocument()
})
```

### 3. Implement Component

Write minimum code to pass the test in `src/components/features/[Component].tsx`

### 4. Verify Coverage

```bash
npm run test:coverage
# Ensure new code has 95%+ coverage
```

### 5. Run E2E Tests

```bash
npm run dev &              # Start dev server
npm run test:e2e           # Run E2E tests
```

### 6. Create PR

```bash
git commit -m "feat([feature]): add [feature description]"
gh pr create --title "feat: Add [feature]"
```

## CI/CD

### GitHub Actions

Every PR runs:
1. Lint (`npm run lint`)
2. Type check (`npm run type-check`)
3. Unit tests (`npm test`)
4. E2E tests (`npm run test:e2e`)
5. Build verification (`npm run build`)

**Merge Requirements**: All checks pass + 1 approved review

### Deployment

- **Staging**: Auto-deploy on merge to `develop` → [staging-url]
- **Production**: Auto-deploy on merge to `main` → [production-url]

**Platform**: [Vercel/Netlify/Cloudflare Pages]

## Environment Variables

```bash
# API Configuration
VITE_API_URL=[http://localhost:3001/api or https://api.example.com]

# Authentication ([Auth0/Clerk/NextAuth])
VITE_AUTH_DOMAIN=[auth-domain]
VITE_AUTH_CLIENT_ID=[client-id]

# Feature Flags (optional)
VITE_ENABLE_ANALYTICS=[true/false]
VITE_ENABLE_NEW_UI=[true/false]

# Other
VITE_LOG_LEVEL=[debug/info/warn/error]
```

**Note**: Variables prefixed with `VITE_` (or `NEXT_PUBLIC_`) are exposed to the browser.

**Never commit sensitive data**. Use `.env.local` for development (gitignored).

## State Management

We use [Zustand/Redux/Context API] for state management.

### Store Structure

```typescript
// src/stores/[storeName].ts
import create from 'zustand'

interface [StoreName]State {
  // State properties
}

export const use[StoreName]Store = create<[StoreName]State>((set) => ({
  // Initial state and actions
}))
```

### Usage in Components

```typescript
import { use[StoreName]Store } from '@/stores/[storeName]'

function Component() {
  const { state, action } = use[StoreName]Store()

  // Use state and actions
}
```

## API Integration

### API Client

Location: `src/services/api/client.ts`

```typescript
import axios from 'axios'

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 10000,
})

// Add auth interceptor
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})
```

### API Service Example

```typescript
// src/services/api/users.ts
import { apiClient } from './client'

export const userService = {
  async getUser(id: string) {
    const { data } = await apiClient.get(`/users/${id}`)
    return data
  },

  async updateUser(id: string, updates: Partial<User>) {
    const { data } = await apiClient.patch(`/users/${id}`, updates)
    return data
  },
}
```

## Routing

We use [React Router/Next.js App Router/TanStack Router] for routing.

### Route Structure

[Describe routing approach - file-based (Next.js) or component-based (React Router)]

```
[routes structure]
```

## Component Guidelines

### Component Structure

```
ComponentName/
├── ComponentName.tsx       # Main component
├── ComponentName.test.tsx  # Tests
├── ComponentName.styles.ts # Styles (if using CSS-in-JS)
└── index.ts                # Re-export
```

### Component Template

```typescript
// src/components/features/ComponentName/ComponentName.tsx
import { FC } from 'react'

interface ComponentNameProps {
  // Props interface
}

export const ComponentName: FC<ComponentNameProps> = (props) => {
  // Component logic
  return (
    <div>
      {/* JSX */}
    </div>
  )
}
```

## Code Quality Standards

- **Test Coverage**: Minimum 95%
- **TypeScript**: Strict mode enabled
- **Linting**: ESLint with [Airbnb/Standard] config
- **Formatting**: Prettier (auto-format on save)
- **Accessibility**: WCAG 2.1 AA compliance

## Branch Strategy

- `main` - Production (protected, requires PR + review)
- `develop` - Integration branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Production hotfixes

## Performance

### Bundle Size

- Keep main bundle < 200KB gzipped
- Use code splitting for routes
- Lazy load heavy components

Check bundle size:
```bash
npm run build:analyze
```

### Core Web Vitals Targets

- **FCP** (First Contentful Paint): < 1.8s
- **LCP** (Largest Contentful Paint): < 2.5s
- **TTI** (Time to Interactive): < 3.8s
- **CLS** (Cumulative Layout Shift): < 0.1

## Troubleshooting

**Issue**: Dev server won't start

**Solution**:
```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

---

**Issue**: Tests fail with "Cannot find module"

**Solution**:
```bash
# Check tsconfig paths are correct
# Verify jest/vitest moduleNameMapper
```

---

**Issue**: Build fails with type errors

**Solution**:
```bash
# Run type check separately to see errors
npm run type-check

# Fix reported errors
```

## Additional Resources

- [Project Documentation](docs/)
- [Component Storybook]([storybook-url])
- [API Documentation]([api-docs-url])
- [Design System]([design-system-url])
