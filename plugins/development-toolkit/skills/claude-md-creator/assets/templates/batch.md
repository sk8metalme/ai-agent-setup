# [Project Name] - Batch Processing

[Brief description of the batch processing system]

**Tech Stack**: [Node.js/Python/Go], [Cron/Bull/Celery/Airflow], [Database], [Message Queue]

## Quick Start

Prerequisites:
- `[runtime]` >= [version]
- `docker` and `docker-compose` (for dependencies)
- Database: [PostgreSQL/MySQL] [version]
- Redis (for job queue)

```bash
npm install
cp .env.example .env
docker-compose up -d                # Start database + Redis
npm run db:migrate                  # Run migrations
npm run worker                      # Start batch worker
npm run schedule                    # Start job scheduler
```

## Common Commands

### Running Batch Jobs
- `npm run job:<job-name>` - Run specific job manually
- `npm run worker` - Start worker (processes queued jobs)
- `npm run schedule` - Start scheduler (schedules recurring jobs)

### Job Management
- `npm run jobs:list` - List all jobs
- `npm run jobs:status` - Check job queue status
- `npm run jobs:clear` - Clear failed jobs
- `npm run jobs:retry <job-id>` - Retry failed job

### Testing
- `npm test` - Run unit tests
- `npm run test:jobs` - Test job handlers
- `npm run test:coverage` - Coverage report (95%+)

### Monitoring
- `npm run monitor` - Monitor job queue
- `npm run metrics` - View job metrics
- `npm run logs` - View job logs

## Project Structure

```
src/
├── jobs/                   # Job definitions
│   ├── dataSync/
│   │   ├── syncUsers.ts
│   │   └── syncUsers.test.ts
│   ├── reports/
│   │   ├── generateDailyReport.ts
│   │   └── generateDailyReport.test.ts
│   └── cleanup/
│       ├── purgeOldData.ts
│       └── purgeOldData.test.ts
├── workers/                # Worker processes
│   ├── jobWorker.ts       # Main job worker
│   └── scheduler.ts       # Job scheduler
├── queue/                  # Queue configuration
│   ├── config.ts
│   └── jobQueue.ts
├── services/               # Shared services
└── utils/
    ├── logger.ts
    └── retry.ts           # Retry logic

config/
├── cron.yaml              # Cron schedules
└── jobs.yaml              # Job configurations

tests/
├── unit/
└── integration/
```

## Job Definitions

### Job Structure

```typescript
// src/jobs/dataSync/syncUsers.ts
import { Job } from 'bull'

export interface SyncUsersJobData {
  source: string
  batchSize: number
  startDate?: string
}

export async function syncUsersJob(job: Job<SyncUsersJobData>) {
  const { source, batchSize, startDate } = job.data

  logger.info('Starting user sync', { source, batchSize })

  // Update job progress
  await job.progress(0)

  try {
    const users = await fetchUsersFromSource(source, { startDate })
    const totalUsers = users.length

    for (let i = 0; i < totalUsers; i += batchSize) {
      const batch = users.slice(i, i + batchSize)
      await syncUserBatch(batch)

      // Update progress
      const progress = Math.round(((i + batchSize) / totalUsers) * 100)
      await job.progress(progress)

      logger.info(`Synced ${i + batchSize}/${totalUsers} users`)
    }

    await job.progress(100)
    logger.info('User sync completed', { totalUsers })

    return { success: true, totalUsers }
  } catch (error) {
    logger.error('User sync failed', { error })
    throw error // Job will be retried based on retry configuration
  }
}
```

### Registering Jobs

```typescript
// src/queue/jobQueue.ts
import Bull from 'bull'
import { syncUsersJob } from '@/jobs/dataSync/syncUsers'
import { generateDailyReportJob } from '@/jobs/reports/generateDailyReport'

const jobQueue = new Bull('batch-jobs', {
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
  },
})

// Register job handlers
jobQueue.process('sync-users', 5, syncUsersJob)      // 5 concurrent jobs
jobQueue.process('daily-report', 1, generateDailyReportJob)
```

## Job Scheduling

### Cron Configuration

```yaml
# config/cron.yaml
jobs:
  - name: sync-users
    schedule: "0 2 * * *"           # Daily at 2 AM
    data:
      source: "external-api"
      batchSize: 1000

  - name: daily-report
    schedule: "0 8 * * 1-5"         # Weekdays at 8 AM
    timezone: "America/New_York"

  - name: cleanup-old-data
    schedule: "0 3 * * 0"           # Weekly on Sunday at 3 AM
    data:
      retentionDays: 90
```

### Scheduler Implementation

```typescript
// src/workers/scheduler.ts
import cron from 'node-cron'
import { jobQueue } from '@/queue/jobQueue'
import scheduleConfig from '@/config/cron.yaml'

export function startScheduler() {
  scheduleConfig.jobs.forEach((job) => {
    cron.schedule(job.schedule, async () => {
      logger.info(`Scheduling job: ${job.name}`)

      await jobQueue.add(job.name, job.data, {
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 2000,
        },
      })
    }, {
      timezone: job.timezone || 'UTC',
    })

    logger.info(`Scheduled: ${job.name} (${job.schedule})`)
  })
}
```

## Queue Configuration

### Retry Strategy

```typescript
// Job retry configuration
const jobOptions = {
  attempts: 3,                         // Retry up to 3 times
  backoff: {
    type: 'exponential',               // Exponential backoff
    delay: 2000,                       // Initial delay: 2 seconds
  },
  timeout: 60000,                      // Timeout: 1 minute
  removeOnComplete: 100,               // Keep last 100 completed jobs
  removeOnFail: 500,                   // Keep last 500 failed jobs
}

await jobQueue.add('sync-users', jobData, jobOptions)
```

### Concurrency

```typescript
// Process jobs with different concurrency levels
jobQueue.process('high-priority', 10, highPriorityHandler)  // 10 concurrent
jobQueue.process('normal', 5, normalHandler)                 // 5 concurrent
jobQueue.process('low-priority', 1, lowPriorityHandler)      // 1 at a time
```

## Error Handling

### Failed Job Handler

```typescript
// src/workers/jobWorker.ts
jobQueue.on('failed', async (job, err) => {
  logger.error('Job failed', {
    jobId: job.id,
    jobName: job.name,
    attempts: job.attemptsMade,
    error: err.message,
  })

  // Send alert if all retries exhausted
  if (job.attemptsMade >= job.opts.attempts) {
    await sendAlert({
      subject: `Job Failed: ${job.name}`,
      message: `Job ${job.id} failed after ${job.attemptsMade} attempts`,
      error: err,
    })
  }
})
```

### Dead Letter Queue

```typescript
// Move permanently failed jobs to dead letter queue
jobQueue.on('failed', async (job, err) => {
  if (job.attemptsMade >= job.opts.attempts) {
    await deadLetterQueue.add('failed-job', {
      originalJob: job.toJSON(),
      error: err.message,
      failedAt: new Date(),
    })
  }
})
```

## Environment Variables

```bash
# Job Queue (Redis)
REDIS_HOST=[localhost]
REDIS_PORT=[6379]
REDIS_PASSWORD=[optional]

# Database
DATABASE_URL=[postgresql://localhost:5432/dbname]

# Job Configuration
JOB_CONCURRENCY=[5]
JOB_TIMEOUT=[60000]                  # milliseconds
JOB_RETRY_ATTEMPTS=[3]
JOB_RETRY_DELAY=[2000]               # milliseconds

# Scheduler
SCHEDULER_ENABLED=[true]
SCHEDULER_TIMEZONE=[UTC]

# Monitoring
METRICS_ENABLED=[true]
METRICS_PORT=[9090]

# Alerts
ALERT_EMAIL=[admin@example.com]
ALERT_SLACK_WEBHOOK=[https://hooks.slack.com/...]
```

## Monitoring

### Job Queue Dashboard

Use Bull Board for visual monitoring:

```typescript
import { createBullBoard } from '@bull-board/api'
import { BullAdapter } from '@bull-board/api/bullAdapter'
import { ExpressAdapter } from '@bull-board/express'

const serverAdapter = new ExpressAdapter()

createBullBoard({
  queues: [new BullAdapter(jobQueue)],
  serverAdapter: serverAdapter,
})

app.use('/admin/queues', serverAdapter.getRouter())
```

Access at: `http://localhost:[port]/admin/queues`

### Metrics

```typescript
// Prometheus metrics
import { register, Counter, Histogram } from 'prom-client'

const jobsProcessed = new Counter({
  name: 'jobs_processed_total',
  help: 'Total number of jobs processed',
  labelNames: ['job_name', 'status'],
})

const jobDuration = new Histogram({
  name: 'job_duration_seconds',
  help: 'Job processing duration',
  labelNames: ['job_name'],
})
```

## Testing

### Unit Tests

```typescript
// src/jobs/dataSync/syncUsers.test.ts
describe('syncUsersJob', () => {
  it('syncs users in batches', async () => {
    const mockJob = {
      data: { source: 'api', batchSize: 100 },
      progress: jest.fn(),
    }

    const result = await syncUsersJob(mockJob as any)

    expect(result.success).toBe(true)
    expect(mockJob.progress).toHaveBeenCalledWith(100)
  })

  it('handles errors and retries', async () => {
    const mockJob = {
      data: { source: 'failing-api', batchSize: 100 },
      progress: jest.fn(),
    }

    await expect(syncUsersJob(mockJob as any)).rejects.toThrow()
  })
})
```

### Integration Tests

```typescript
// Test actual job queue
describe('Job Queue (integration)', () => {
  it('processes jobs from queue', async () => {
    const job = await jobQueue.add('sync-users', {
      source: 'test',
      batchSize: 10,
    })

    await job.finished()  // Wait for completion

    expect(job.returnvalue.success).toBe(true)
  })
})
```

## Deployment

### Docker

```dockerfile
# Dockerfile
FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Worker process
CMD ["npm", "run", "worker"]
```

### Docker Compose

```yaml
# docker-compose.yml
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  batch-worker:
    build: .
    command: npm run worker
    environment:
      REDIS_HOST: redis
      DATABASE_URL: postgresql://db:5432/myapp
    depends_on:
      - redis
      - postgres

  batch-scheduler:
    build: .
    command: npm run schedule
    environment:
      REDIS_HOST: redis
    depends_on:
      - redis
```

### Production

- **Scaling**: Run multiple worker instances for parallelism
- **Monitoring**: Use Bull Board + Prometheus + Grafana
- **Alerting**: Alert on failed jobs, queue backlog
- **Resource Limits**: Set memory/CPU limits per worker

## Troubleshooting

**Issue**: Jobs not being processed

**Solution**:
- Check Redis connection: `redis-cli ping`
- Verify worker is running: `docker-compose ps`
- Check job queue: `npm run jobs:status`

---

**Issue**: Jobs timing out

**Solution**:
- Increase timeout in job options
- Break large jobs into smaller batches
- Optimize job handler performance

---

**Issue**: Memory leaks in long-running workers

**Solution**:
- Implement graceful restart: restart worker every N jobs
- Monitor memory usage
- Fix memory leaks in job handlers

## Best Practices

1. **Idempotency**: Make jobs idempotent (safe to run multiple times)
2. **Small Batches**: Process data in small batches to avoid timeouts
3. **Progress Updates**: Update job progress for monitoring
4. **Error Handling**: Always handle errors and log them
5. **Retry Logic**: Configure appropriate retry attempts and backoff
6. **Monitoring**: Monitor queue depth, job duration, failure rate
7. **Graceful Shutdown**: Handle SIGTERM to finish current jobs
8. **Resource Limits**: Set appropriate memory/CPU limits
