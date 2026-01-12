# [Project Name] API

[Brief 1-2 sentence description of what this API does]

**Tech Stack**: [Node.js/Python/Go] [version], [Express/FastAPI/Gin], [PostgreSQL/MySQL/MongoDB], TypeScript/Python

## Quick Start

Prerequisites:
- `node` >= [version] or `python` >= [version]
- `docker` and `docker-compose`
- Database: [PostgreSQL/MySQL/MongoDB] [version]

```bash
npm install                   # or: pip install -r requirements.txt
cp .env.example .env         # Configure environment
docker-compose up -d         # Start database + Redis
npm run db:migrate           # Run migrations
npm run db:seed              # Seed test data (optional)
npm run dev                  # Start at http://localhost:[port]
```

**Verify**: `curl http://localhost:[port]/health` should return `{"status":"ok"}`

## Common Commands

### Development
- `npm run dev` - Start with hot reload
- `npm run dev:debug` - Start with debugger (port 9229)
- `npm run dev:watch` - Watch mode

### Testing (TDD Required)
- `npm test` - Run all tests ([Jest/Pytest])
- `npm test -- --watch` - Watch mode for TDD
- `npm run test:integration` - Integration tests
- `npm run test:e2e` - E2E API tests
- `npm run test:coverage` - Coverage report (target: 95%+)

### Database
- `npm run db:migrate` - Run migrations
- `npm run db:migrate:rollback` - Rollback last migration
- `npm run db:seed` - Seed database
- `npm run db:reset` - Reset database (destructive!)

### Code Quality
- `npm run lint` - Run linter
- `npm run type-check` - TypeScript check (or mypy for Python)
- `npm run format` - Format code

### Build
- `npm run build` - Compile TypeScript (or package Python)
- `npm start` - Run production build

## Project Structure

```
src/
├── api/
│   ├── routes/             # Route definitions
│   │   ├── index.ts       # Route registry
│   │   ├── auth.ts        # Authentication routes
│   │   ├── users.ts       # User routes
│   │   └── [resource].ts  # Resource routes
│   ├── middlewares/        # Express middlewares
│   │   ├── auth.ts        # Authentication middleware
│   │   ├── errorHandler.ts
│   │   ├── validation.ts
│   │   └── rateLimit.ts
│   └── validators/         # Request validation ([Joi/Zod/Pydantic])
├── services/               # Business logic
│   ├── auth/
│   │   ├── authService.ts
│   │   └── authService.test.ts
│   └── users/
│       ├── userService.ts
│       └── userService.test.ts
├── models/                 # Database models ([Prisma/TypeORM/SQLAlchemy])
│   ├── User.ts
│   └── Post.ts
├── database/               # Database configuration
│   ├── client.ts           # Database client
│   └── migrations/         # Migration files
├── utils/                  # Utilities
│   ├── logger.ts          # [Winston/Pino/Python logging]
│   └── errors.ts          # Custom error classes
├── config/                 # Configuration
│   ├── database.ts
│   ├── auth.ts
│   └── index.ts
└── types/                  # TypeScript types

tests/
├── unit/                   # Unit tests
├── integration/            # Integration tests
└── e2e/                    # API E2E tests

scripts/
├── seed.ts                 # Database seeding
└── migrate.ts              # Migration runner
```

**Key Files**:
- `src/index.ts` or `src/main.py` - Application entry point
- `src/api/routes/index.ts` - Route registry
- `src/config/database.ts` - Database configuration
- `.env.example` - Environment variable template

## Development Workflow (TDD)

### 1. Write Test First

```bash
touch tests/unit/services/user/createUser.test.ts
npm test -- --watch tests/unit/services/user/createUser.test.ts
```

Example test:
```typescript
import { createUser } from '@/services/user/userService'

describe('createUser', () => {
  it('creates a new user', async () => {
    const userData = { email: 'test@example.com', name: 'Test User' }
    const user = await createUser(userData)

    expect(user).toHaveProperty('id')
    expect(user.email).toBe('test@example.com')
  })

  it('throws error for duplicate email', async () => {
    const userData = { email: 'existing@example.com', name: 'Test' }
    await expect(createUser(userData)).rejects.toThrow('Email already exists')
  })
})
```

### 2. Implement Service

```typescript
// src/services/user/userService.ts
export async function createUser(data: CreateUserDto) {
  // Check if email exists
  const existing = await db.user.findUnique({ where: { email: data.email } })
  if (existing) {
    throw new ConflictError('Email already exists')
  }

  // Create user
  return await db.user.create({ data })
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

### 5. Create PR

```bash
git commit -m "feat(users): add user creation endpoint"
gh pr create --title "feat: Add user creation endpoint"
```

## API Documentation

- **Local**: http://localhost:[port]/api-docs ([Swagger UI/ReDoc])
- **Staging**: https://api-staging.example.com/api-docs
- **Production**: https://api.example.com/api-docs

### Generating API Docs

Documentation is auto-generated from:
- **OpenAPI/Swagger**: JSDoc comments or decorators
- **[FastAPI]**: Pydantic models (automatic)

Example route documentation:
```typescript
/**
 * @swagger
 * /users:
 *   post:
 *     summary: Create a new user
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateUserDto'
 *     responses:
 *       201:
 *         description: User created successfully
 *       409:
 *         description: Email already exists
 */
router.post('/users', createUserHandler)
```

## Environment Variables

```bash
# Server
NODE_ENV=[development/staging/production]
PORT=[3000]
API_URL=[http://localhost:3000]

# Database
DATABASE_URL=[postgresql://user:pass@localhost:5432/dbname]

# Redis (optional)
REDIS_URL=[redis://localhost:6379]

# Authentication
JWT_SECRET=[your-secret-key]              # Generate: openssl rand -base64 32
JWT_EXPIRES_IN=[24h]

# External Services
STRIPE_SECRET_KEY=[sk_test_xxx]           # Stripe Dashboard → API Keys
SENDGRID_API_KEY=[SG.xxx]                 # SendGrid → Settings → API Keys

# Feature Flags (optional)
FEATURE_NEW_CHECKOUT=[false]
FEATURE_ANALYTICS=[true]

# Logging
LOG_LEVEL=[debug/info/warn/error]
```

**Security**:
- Never commit `.env` (already in `.gitignore`)
- Use different secrets for dev/staging/prod
- Rotate secrets regularly

## Database

### Migrations

We use [Prisma/TypeORM/Alembic/Knex] for migrations.

**Create Migration**:
```bash
npm run db:migrate:create add-users-table
```

**Run Migrations**:
```bash
npm run db:migrate
```

**Rollback**:
```bash
npm run db:migrate:rollback
```

### Seeding

```bash
npm run db:seed
```

Seeds:
- 10 test users
- 50 sample posts
- 200 comments

**Custom seed data**: Edit `scripts/seed.ts`

### Schema

```sql
-- Example schema structure
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## Authentication

### JWT-based Authentication

**Login Flow**:
1. User sends credentials to `/auth/login`
2. Server validates credentials
3. Server generates JWT access token + refresh token
4. Client stores tokens (httpOnly cookies or localStorage)
5. Client sends token in `Authorization: Bearer <token>` header

**Endpoints**:
- `POST /auth/login` - Login with email/password
- `POST /auth/register` - Register new user
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout (invalidate tokens)

**Protected Routes**:
```typescript
import { authenticate } from '@/api/middlewares/auth'

router.get('/users/me', authenticate, getUserProfile)
```

### Rate Limiting

Applied to authentication endpoints:
- Login: 5 requests per 15 minutes
- Register: 3 requests per hour
- Password reset: 3 requests per hour

```typescript
import rateLimit from 'express-rate-limit'

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
  message: 'Too many login attempts, please try again later'
})

router.post('/auth/login', loginLimiter, loginHandler)
```

## API Response Format

### Success Response

```json
{
  "success": true,
  "data": {
    "id": "123",
    "email": "user@example.com",
    "name": "John Doe"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email address",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email"
      }
    ]
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "requestId": "req_abc123"
  }
}
```

## CI/CD

### GitHub Actions

Every PR runs:
1. Lint + Type check
2. Unit tests
3. Integration tests (with PostgreSQL service)
4. E2E API tests
5. Build verification
6. Security audit

### Deployment

- **Staging**: Auto-deploy on merge to `develop`
- **Production**: Auto-deploy on merge to `main` (requires manual approval)

**Platform**: [Railway/Render/AWS/Heroku]

## Security

### Best Practices

1. **Input Validation**: Validate all inputs with [Joi/Zod/Pydantic]
2. **SQL Injection**: Use parameterized queries (ORM handles this)
3. **XSS**: Sanitize user input
4. **CSRF**: Use CSRF tokens for state-changing operations
5. **Rate Limiting**: Protect all public endpoints
6. **HTTPS Only**: Enforce HTTPS in production
7. **Security Headers**: Use [Helmet.js] middleware

```typescript
import helmet from 'helmet'

app.use(helmet())
app.use(cors({ origin: process.env.FRONTEND_URL, credentials: true }))
```

### Security Checklist

- [ ] Environment variables for all configs
- [ ] JWT tokens expire (< 24h)
- [ ] Rate limiting on auth endpoints
- [ ] CORS configured correctly
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (input sanitization)
- [ ] HTTPS enforced in production
- [ ] Security headers configured

## Performance

### Database Optimization

1. **Indexes**: Add indexes on frequently queried columns
2. **Query Optimization**: Use `EXPLAIN` to analyze slow queries
3. **Connection Pooling**: Configure database connection pool
4. **Caching**: Use Redis for frequently accessed data

```typescript
// Redis caching example
async function getUser(id: string) {
  // Check cache first
  const cached = await redis.get(`user:${id}`)
  if (cached) return JSON.parse(cached)

  // Query database
  const user = await db.user.findUnique({ where: { id } })

  // Cache result (5 minutes TTL)
  await redis.setex(`user:${id}`, 300, JSON.stringify(user))

  return user
}
```

### Response Time Targets

- **p50**: < 100ms
- **p95**: < 500ms
- **p99**: < 1000ms

## Troubleshooting

**Issue**: Database connection fails

**Solution**:
```bash
# Check Docker containers
docker-compose ps

# Restart database
docker-compose restart postgres

# Check connection string
echo $DATABASE_URL
```

---

**Issue**: Migrations fail

**Solution**:
```bash
# Rollback last migration
npm run db:migrate:rollback

# Fix migration file
# Re-run migration
npm run db:migrate
```

---

**Issue**: Tests fail with timeout

**Solution**:
```bash
# Increase Jest timeout
# jest.config.js: testTimeout: 10000 (10 seconds)

# Or use --testTimeout flag
npm test -- --testTimeout=10000
```

## Additional Resources

- [API Documentation](http://localhost:[port]/api-docs)
- [Database Schema](docs/schema.md)
- [Postman Collection](docs/postman_collection.json)
- [Architecture Diagram](docs/architecture.md)
