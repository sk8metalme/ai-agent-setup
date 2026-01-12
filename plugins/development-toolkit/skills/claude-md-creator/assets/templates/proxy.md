# [Project Name] - API Gateway/Proxy

[Brief description of the proxy/gateway service]

**Tech Stack**: [Nginx/Envoy/Kong/Express Gateway], [Node.js/Go], [Rate Limiting/Auth/Caching]

## Quick Start

Prerequisites:
- `[runtime]` >= [version] (if applicable)
- `docker` and `docker-compose`

```bash
cp .env.example .env
docker-compose up -d                # Start proxy and upstream services
curl http://localhost:[port]/health # Verify proxy is running
```

## Common Commands

### Development
- `npm run dev` - Start proxy in development mode
- `npm run reload` - Reload configuration without downtime
- `docker-compose up` - Start all services

### Configuration
- `npm run validate:config` - Validate configuration
- `npm run test:routes` - Test routing rules
- `npm run generate:config` - Generate config from template

### Monitoring
- `npm run logs` - View access logs
- `npm run metrics` - View metrics dashboard
- `npm run health` - Health check all upstreams

## Configuration Structure

```
config/
├── nginx.conf              # Main Nginx config (or equivalent)
├── routes.yaml             # Route definitions
├── upstream.yaml           # Upstream service definitions
├── ratelimit.yaml          # Rate limiting rules
└── ssl/                    # SSL certificates

src/                        # For programmable proxies (Express Gateway, etc.)
├── plugins/                # Custom plugins
├── middlewares/            # Middlewares (auth, logging, etc.)
└── routes/                 # Route handlers

tests/
├── integration/            # Integration tests
└── load/                   # Load testing scripts
```

## Routing Configuration

### Route Definitions

```yaml
# config/routes.yaml
routes:
  - name: api-v1
    match:
      path: /api/v1/*
      methods: [GET, POST, PUT, DELETE]
    upstream: backend-api
    plugins:
      - auth
      - rate-limit
      - cors

  - name: auth-service
    match:
      path: /auth/*
    upstream: auth-service
    plugins:
      - rate-limit

  - name: static-assets
    match:
      path: /assets/*
    upstream: cdn
    cache: true
    cache_ttl: 3600  # 1 hour
```

### Upstream Services

```yaml
# config/upstream.yaml
upstreams:
  backend-api:
    servers:
      - url: http://api-service:3000
        weight: 1
      - url: http://api-service-2:3000
        weight: 1
    health_check:
      path: /health
      interval: 10s
      timeout: 5s
      unhealthy_threshold: 3

  auth-service:
    servers:
      - url: http://auth:3001
    health_check:
      path: /health
      interval: 5s
```

## Features

### Rate Limiting

```yaml
# config/ratelimit.yaml
rate_limits:
  - name: api-limit
    limit: 100                    # requests
    window: 60                    # seconds
    scope: ip                     # per IP address

  - name: auth-limit
    limit: 5
    window: 900                   # 15 minutes
    scope: ip
    paths:
      - /auth/login
      - /auth/register
```

### Authentication

JWT validation example:

```javascript
// src/middlewares/auth.js
async function validateJWT(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '')

  if (!token) {
    return res.status(401).json({ error: 'Missing authorization token' })
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET)
    req.user = payload
    next()
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' })
  }
}
```

### CORS

```yaml
# CORS configuration
cors:
  allowed_origins:
    - https://example.com
    - https://staging.example.com
  allowed_methods:
    - GET
    - POST
    - PUT
    - DELETE
    - OPTIONS
  allowed_headers:
    - Content-Type
    - Authorization
  expose_headers:
    - X-Request-ID
  max_age: 86400  # 24 hours
  allow_credentials: true
```

### Caching

```yaml
# Caching rules
cache:
  - path: /api/v1/public/*
    ttl: 300                      # 5 minutes
    vary: [Accept-Encoding]

  - path: /api/v1/static/*
    ttl: 3600                     # 1 hour
    cache_key: url
```

## Load Balancing

### Strategies

- **Round Robin** (default): Distribute requests evenly
- **Least Connections**: Route to server with fewest active connections
- **IP Hash**: Route based on client IP (session affinity)
- **Weighted**: Route based on server weight

```yaml
# Load balancing configuration
upstreams:
  backend:
    strategy: round-robin         # or: least-connections, ip-hash, weighted
    servers:
      - url: http://server1:3000
        weight: 2
      - url: http://server2:3000
        weight: 1
```

## SSL/TLS

### Certificate Configuration

```yaml
# SSL configuration
ssl:
  enabled: true
  certificate: /etc/ssl/certs/example.com.crt
  certificate_key: /etc/ssl/private/example.com.key
  protocols: [TLSv1.2, TLSv1.3]
  ciphers: HIGH:!aNULL:!MD5
  redirect_http: true               # Redirect HTTP to HTTPS
```

### Let's Encrypt Auto-Renewal

```bash
# Setup certbot
docker-compose exec proxy certbot --nginx -d example.com

# Auto-renewal (cron)
0 3 * * * docker-compose exec proxy certbot renew --quiet
```

## Environment Variables

```bash
# Proxy Configuration
PROXY_PORT=[80]
PROXY_SSL_PORT=[443]
UPSTREAM_API_URL=[http://api-service:3000]
UPSTREAM_AUTH_URL=[http://auth-service:3001]

# Rate Limiting
RATE_LIMIT_ENABLED=[true]
RATE_LIMIT_MAX=[100]
RATE_LIMIT_WINDOW=[60]

# Authentication
JWT_SECRET=[your-jwt-secret]
JWT_ISSUER=[your-issuer]

# Caching
CACHE_ENABLED=[true]
CACHE_TTL=[300]
REDIS_URL=[redis://localhost:6379]  # For distributed caching

# Monitoring
ACCESS_LOG_ENABLED=[true]
METRICS_ENABLED=[true]
METRICS_PORT=[9090]
```

## Monitoring

### Access Logs

```bash
# View access logs
docker-compose logs -f proxy

# Analyze logs
cat logs/access.log | awk '{print $9}' | sort | uniq -c | sort -rn  # Status code distribution
```

### Metrics

Expose Prometheus metrics:

```yaml
# /metrics endpoint
metrics:
  enabled: true
  port: 9090
  path: /metrics
```

Key metrics:
- Request rate (req/s)
- Response time (p50, p95, p99)
- Error rate (4xx, 5xx)
- Upstream health
- Cache hit rate

## Testing

### Integration Tests

```javascript
// tests/integration/routing.test.js
describe('Proxy Routing', () => {
  it('routes /api/v1/* to backend', async () => {
    const response = await fetch('http://localhost/api/v1/users')
    expect(response.status).toBe(200)
  })

  it('applies rate limiting', async () => {
    // Send 101 requests (limit is 100)
    const requests = Array(101).fill(null).map(() =>
      fetch('http://localhost/api/v1/test')
    )
    const responses = await Promise.all(requests)
    const rateLimited = responses.filter(r => r.status === 429)
    expect(rateLimited.length).toBeGreaterThan(0)
  })
})
```

### Load Testing

```bash
# Using Apache Bench
ab -n 10000 -c 100 http://localhost/api/v1/test

# Using k6
k6 run tests/load/load-test.js
```

## Deployment

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'
services:
  proxy:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./config/nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - api-service
      - auth-service

  api-service:
    image: my-api:latest
    environment:
      PORT: 3000

  auth-service:
    image: my-auth:latest
    environment:
      PORT: 3001
```

### Production

- **High Availability**: Run multiple proxy instances behind load balancer
- **Auto-scaling**: Scale based on CPU/memory/request rate
- **Health Checks**: Monitor upstream health continuously
- **Circuit Breaking**: Fail fast when upstreams are down

## Troubleshooting

**Issue**: 502 Bad Gateway

**Solution**:
- Check upstream services are running: `docker-compose ps`
- Verify upstream URLs in configuration
- Check upstream health endpoints

---

**Issue**: Rate limiting not working

**Solution**:
- Verify Redis is running (for distributed rate limiting)
- Check rate limit configuration
- Ensure client IP is correctly identified (check X-Forwarded-For)

---

**Issue**: SSL certificate errors

**Solution**:
```bash
# Verify certificate
openssl x509 -in /etc/ssl/certs/example.com.crt -text -noout

# Test SSL connection
openssl s_client -connect example.com:443
```

## Best Practices

1. **Health Checks**: Always configure upstream health checks
2. **Rate Limiting**: Protect all public endpoints
3. **Caching**: Cache static and public API responses
4. **Logging**: Log all requests for debugging and analytics
5. **SSL/TLS**: Always use HTTPS in production
6. **Monitoring**: Monitor request rate, latency, error rate
7. **Circuit Breaking**: Prevent cascading failures
8. **Timeouts**: Configure request/response timeouts
