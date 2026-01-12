# CI/CD Guide

This guide explains how to document CI/CD pipelines and deployment processes in CLAUDE.md.

## CI/CD Overview

### Documenting Your Pipeline

```markdown
## CI/CD Pipeline

### Continuous Integration (CI)

**Trigger**: On every push to any branch + Pull Requests

**Platform**: GitHub Actions / GitLab CI / CircleCI / Jenkins

**Pipeline Steps**:

1. **Setup** (~30s)
   - Checkout code
   - Install dependencies
   - Cache node_modules

2. **Lint** (~30s)
   ```bash
   npm run lint
   ```

3. **Type Check** (~45s)
   ```bash
   npm run type-check
   ```

4. **Unit Tests** (~2min)
   ```bash
   npm test -- --coverage
   ```
   - Fails if coverage < 95%

5. **Integration Tests** (~3min)
   ```bash
   npm run test:integration
   ```

6. **E2E Tests** (~5min)
   ```bash
   npm run test:e2e
   ```

7. **Build Verification** (~1min)
   ```bash
   npm run build
   ```

8. **Security Scan** (~2min)
   ```bash
   npm audit
   snyk test
   ```

**Total Time**: ~15 minutes

**Status Checks Required for Merge**:
- ✅ All tests pass
- ✅ Coverage threshold met (95%+)
- ✅ No high/critical security vulnerabilities
- ✅ Build succeeds
- ✅ 1+ approved code review

### Continuous Deployment (CD)

**Staging Deployment**:
- **Trigger**: Merge to `develop` branch
- **Target**: https://staging.example.com
- **Auto-deploy**: Yes
- **Rollback**: Automatic on health check failure

**Production Deployment**:
- **Trigger**: Merge to `main` branch
- **Target**: https://example.com
- **Auto-deploy**: Yes (with manual approval gate)
- **Rollback**: Manual via GitHub Actions
- **Health Checks**: 5-minute warmup period
```

## GitHub Actions Configuration

### Complete Workflow Example

```markdown
## GitHub Actions Workflow

Configuration: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run type-check

      - name: Run tests
        run: npm test -- --coverage
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

      - name: Build
        run: npm run build

      - name: E2E tests
        run: npm run test:e2e

  deploy-staging:
    needs: test
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Vercel Staging
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'

  deploy-production:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Production
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
```

### Managing Secrets

**GitHub Secrets** (Settings → Secrets and variables → Actions):
- `VERCEL_TOKEN`
- `ORG_ID`
- `PROJECT_ID`
- `DATABASE_URL` (for CI)

**Never commit secrets to the repository**.
```

## Deployment Platforms

### Vercel

```markdown
## Deployment (Vercel)

### Automatic Deployments

**Preview Deployments**:
- Every PR gets a preview URL
- Automatically updated on new commits
- Example: `https://my-app-pr-123.vercel.app`

**Production Deployment**:
- Merge to `main` → Auto-deploy to production
- URL: https://example.com

### Manual Deployment

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy to staging
vercel

# Deploy to production
vercel --prod
```

### Environment Variables

Set in Vercel Dashboard (Settings → Environment Variables):

**Production**:
- `DATABASE_URL`
- `API_KEY`
- `NEXT_PUBLIC_API_URL=https://api.example.com`

**Preview**:
- `DATABASE_URL` (separate staging database)
- `API_KEY` (test key)
- `NEXT_PUBLIC_API_URL=https://api-staging.example.com`

### Rollback

```bash
# List deployments
vercel ls

# Promote previous deployment
vercel promote <deployment-url>
```
```

### Railway / Render

```markdown
## Deployment (Railway)

### Automatic Deployment

- **Trigger**: Push to `main` branch
- **Build**: Automatic via Dockerfile or Nixpacks
- **URL**: https://my-app.up.railway.app

### Configuration

**railway.json**:
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "npm start",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### Environment Variables

Set in Railway Dashboard:
- `DATABASE_URL` (automatically provided for PostgreSQL service)
- `API_KEY`
- `NODE_ENV=production`

### Logs

```bash
# View logs
railway logs

# Follow logs
railway logs --follow
```

### Rollback

Railway Dashboard → Deployments → Select previous deployment → Redeploy
```

### Docker Deployment

```markdown
## Deployment (Docker + Kubernetes)

### Building Docker Image

**Dockerfile**:
```dockerfile
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**Build and Push**:
```bash
# Build image
docker build -t myapp:v1.2.3 .

# Tag for registry
docker tag myapp:v1.2.3 ghcr.io/myorg/myapp:v1.2.3
docker tag myapp:v1.2.3 ghcr.io/myorg/myapp:latest

# Push to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
docker push ghcr.io/myorg/myapp:v1.2.3
docker push ghcr.io/myorg/myapp:latest
```

### Kubernetes Deployment

**deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: ghcr.io/myorg/myapp:v1.2.3
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: myapp-secrets
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

**Deploy**:
```bash
# Apply configuration
kubectl apply -f deployment.yaml

# Check status
kubectl rollout status deployment/myapp

# Rollback
kubectl rollout undo deployment/myapp
```
```

## Environment Management

### Environment Variables

```markdown
## Environment Configuration

### Development (.env.local)

Never committed to Git. Copy from `.env.example`:

```bash
cp .env.example .env.local
```

**Required Variables**:
```
NODE_ENV=development
DATABASE_URL=postgresql://localhost:5432/myapp_dev
API_KEY=dev-api-key-12345
NEXT_PUBLIC_API_URL=http://localhost:3000/api
```

### Staging

Configured in deployment platform (Vercel/Railway/etc.):

```
NODE_ENV=staging
DATABASE_URL=postgresql://staging-db-url
API_KEY=staging-api-key
NEXT_PUBLIC_API_URL=https://api-staging.example.com
```

### Production

Configured in deployment platform with production credentials:

```
NODE_ENV=production
DATABASE_URL=postgresql://production-db-url
API_KEY=production-api-key
NEXT_PUBLIC_API_URL=https://api.example.com
```

### Secrets Management

**Development**: Use `.env.local` (gitignored)
**CI/CD**: Use GitHub Secrets
**Production**: Use platform's secret management (Vercel, Railway, AWS Secrets Manager)

**Never**:
- Commit secrets to Git
- Share secrets in Slack/email
- Use production secrets in development
```

## Database Migrations

```markdown
## Database Migrations (CI/CD)

### Migration Strategy

**Development**:
```bash
npm run db:migrate        # Apply migrations
npm run db:migrate:down   # Rollback last migration
```

**CI/CD**:
1. Migrations run automatically before deployment
2. If migration fails, deployment is aborted
3. Use backward-compatible migrations for zero-downtime deployments

### Example Migration Workflow

**GitHub Actions**:
```yaml
- name: Run database migrations
  run: npm run db:migrate
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}

- name: Deploy application
  if: success()
  run: npm run deploy
```

### Zero-Downtime Migrations

**Bad** (causes downtime):
```sql
ALTER TABLE users DROP COLUMN old_email;
```

**Good** (backward compatible):
```sql
-- Step 1: Add new column (deploy v1)
ALTER TABLE users ADD COLUMN email VARCHAR(255);

-- Step 2: Migrate data (run migration)
UPDATE users SET email = old_email WHERE email IS NULL;

-- Step 3: Remove old column (deploy v2, after v1 is stable)
ALTER TABLE users DROP COLUMN old_email;
```
```

## Monitoring and Rollback

### Health Checks

```markdown
## Health Checks

### Endpoint

`GET /health` returns:

```json
{
  "status": "healthy",
  "version": "1.2.3",
  "uptime": 3600,
  "database": "connected",
  "redis": "connected"
}
```

### Monitoring

**Application Performance Monitoring**:
- Sentry (errors)
- DataDog / New Relic (performance)
- Pingdom / UptimeRobot (uptime)

**Alerts**:
- Error rate > 1%
- Response time > 500ms (p95)
- CPU usage > 80%
- Memory usage > 90%

### Deployment Status

Check deployment status:
```bash
curl https://example.com/health
```

Expected response: `{"status":"healthy"}`
```

### Rollback Procedures

```markdown
## Rollback Procedures

### Automatic Rollback

Deployments automatically rollback if:
- Health check fails after 5 minutes
- Error rate > 5%
- No successful requests in 2 minutes

### Manual Rollback

**Vercel**:
```bash
vercel ls                      # List deployments
vercel promote <previous-url>  # Promote previous deployment
```

**Railway**:
Railway Dashboard → Deployments → Previous deployment → Redeploy

**Kubernetes**:
```bash
kubectl rollout undo deployment/myapp
```

**Docker**:
```bash
docker service update --image myapp:v1.2.2 myapp-service
```

### Post-Rollback

1. Investigate root cause
2. Fix issue in development
3. Create new PR with fix
4. Re-deploy after tests pass
```

## Best Practices

### CI/CD Best Practices

```markdown
## CI/CD Best Practices

1. **Fast Feedback**
   - Keep CI pipeline < 15 minutes
   - Run linting/type-checking first (fail fast)
   - Parallelize test suites

2. **Fail Early**
   - Lint → Type Check → Unit → Integration → E2E
   - Stop pipeline on first failure

3. **Idempotent Deployments**
   - Same commit always produces same result
   - Use exact dependency versions (package-lock.json)

4. **Environment Parity**
   - Staging mirrors production
   - Use same Node.js/Python versions
   - Same database versions

5. **Secrets Management**
   - Never commit secrets
   - Rotate secrets regularly
   - Use platform secret managers

6. **Monitoring**
   - Monitor every deployment
   - Set up alerts for errors
   - Track deployment frequency

7. **Rollback Ready**
   - Test rollback procedures
   - Keep previous versions available
   - Automated rollback on failure

8. **Database Migrations**
   - Always backward compatible
   - Test migrations in staging first
   - Have rollback plan for migrations
```

## Example Complete Pipeline

```markdown
## Complete CI/CD Example

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:

env:
  NODE_VERSION: '20'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm test -- --coverage
      - run: npm run build

      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  deploy-staging:
    needs: test
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Staging
        run: ./scripts/deploy-staging.sh
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}

  deploy-production:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Production
        run: ./scripts/deploy-production.sh
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}

      - name: Notify Slack
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "🚀 Deployed to production: ${{ github.sha }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```
```
