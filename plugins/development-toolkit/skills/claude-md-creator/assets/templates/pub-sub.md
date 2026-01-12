# [Project Name] - Pub/Sub System

[Brief description of the messaging/event-driven system]

**Tech Stack**: [Kafka/RabbitMQ/Redis Pub/Sub/Google Cloud Pub/Sub], [Node.js/Python/Go], [Consumer Framework]

## Quick Start

Prerequisites:
- `[runtime]` >= [version]
- `docker` and `docker-compose`
- Message broker: [Kafka/RabbitMQ/etc.] [version]

```bash
npm install                          # Install dependencies
cp .env.example .env                # Configure environment
docker-compose up -d                # Start message broker
npm run topics:create               # Create topics/queues
npm run consumer                    # Start consumer
npm run producer                    # Start producer (in another terminal)
```

## Common Commands

### Development
- `npm run consumer` - Start message consumer
- `npm run producer` - Start message producer
- `npm run worker` - Start background worker

### Topics/Queues Management
- `npm run topics:create` - Create topics/queues
- `npm run topics:list` - List all topics/queues
- `npm run topics:delete <name>` - Delete topic/queue

### Testing
- `npm test` - Run unit tests
- `npm run test:integration` - Integration tests with test broker
- `npm run test:coverage` - Coverage report (95%+)

### Monitoring
- `npm run monitor` - Monitor message throughput
- `npm run lag:check` - Check consumer lag
- `npm run health` - Health check

## Project Structure

```
src/
├── producers/              # Message producers
│   ├── userEventProducer.ts
│   └── orderEventProducer.ts
├── consumers/              # Message consumers
│   ├── userEventConsumer.ts
│   └── orderEventConsumer.ts
├── handlers/               # Message handlers (business logic)
│   ├── userHandlers.ts
│   └── orderHandlers.ts
├── schemas/                # Message schemas (Avro/Protobuf/JSON Schema)
│   ├── userEvents.avsc
│   └── orderEvents.avsc
├── config/                 # Configuration
│   ├── broker.ts          # Broker connection
│   └── topics.ts          # Topic/queue definitions
└── utils/
    ├── logger.ts
    └── retry.ts           # Retry logic

tests/
├── unit/
├── integration/
└── fixtures/              # Test messages
```

## Topics/Queues Configuration

### Topic Definitions

```typescript
// src/config/topics.ts
export const TOPICS = {
  USER_EVENTS: 'user.events',
  ORDER_EVENTS: 'order.events',
  NOTIFICATION_EVENTS: 'notification.events',
} as const

export const TOPIC_CONFIG = {
  [TOPICS.USER_EVENTS]: {
    partitions: 3,
    replicationFactor: 2,
    retentionMs: 7 * 24 * 60 * 60 * 1000, // 7 days
  },
  [TOPICS.ORDER_EVENTS]: {
    partitions: 5,
    replicationFactor: 2,
    retentionMs: 30 * 24 * 60 * 60 * 1000, // 30 days
  },
}
```

### Creating Topics

```bash
npm run topics:create
```

## Message Schema

### Event Structure

```typescript
// src/schemas/userEvents.ts
export interface UserCreatedEvent {
  eventId: string
  eventType: 'user.created'
  timestamp: string
  data: {
    userId: string
    email: string
    name: string
  }
  metadata: {
    version: string
    source: string
  }
}
```

### Schema Validation

We use [Avro/Protobuf/JSON Schema] for message validation:

```typescript
import { validateMessage } from '@/utils/validation'

const message: UserCreatedEvent = {
  eventId: uuid(),
  eventType: 'user.created',
  timestamp: new Date().toISOString(),
  data: { userId: '123', email: 'user@example.com', name: 'John' },
  metadata: { version: '1.0.0', source: 'user-service' }
}

// Validate before publishing
validateMessage(message, UserCreatedEventSchema)
```

## Producer Implementation

### Publishing Messages

```typescript
// src/producers/userEventProducer.ts
import { kafka } from '@/config/broker'
import { TOPICS } from '@/config/topics'

const producer = kafka.producer()

export async function publishUserCreatedEvent(user: User) {
  const event: UserCreatedEvent = {
    eventId: uuid(),
    eventType: 'user.created',
    timestamp: new Date().toISOString(),
    data: {
      userId: user.id,
      email: user.email,
      name: user.name,
    },
    metadata: {
      version: '1.0.0',
      source: 'user-service',
    },
  }

  await producer.send({
    topic: TOPICS.USER_EVENTS,
    messages: [
      {
        key: event.data.userId,
        value: JSON.stringify(event),
        headers: {
          'event-type': event.eventType,
          'event-id': event.eventId,
        },
      },
    ],
  })

  logger.info('Published user.created event', { userId: user.id })
}
```

### Producer Best Practices

1. **Idempotent Producer**: Use `idempotent: true` to prevent duplicate messages
2. **Partitioning**: Use meaningful keys (e.g., userId) for consistent partitioning
3. **Batching**: Configure batch size for throughput
4. **Retry**: Configure retry policy
5. **Monitoring**: Log all published messages

## Consumer Implementation

### Consuming Messages

```typescript
// src/consumers/userEventConsumer.ts
import { kafka } from '@/config/broker'
import { TOPICS } from '@/config/topics'
import { handleUserCreated } from '@/handlers/userHandlers'

const consumer = kafka.consumer({ groupId: 'user-event-processor' })

export async function startUserEventConsumer() {
  await consumer.connect()
  await consumer.subscribe({ topic: TOPICS.USER_EVENTS, fromBeginning: false })

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const event = JSON.parse(message.value.toString())

      try {
        // Route to appropriate handler
        switch (event.eventType) {
          case 'user.created':
            await handleUserCreated(event)
            break
          case 'user.updated':
            await handleUserUpdated(event)
            break
          default:
            logger.warn('Unknown event type', { eventType: event.eventType })
        }
      } catch (error) {
        logger.error('Failed to process message', { error, event })
        // Handle error (dead letter queue, retry, etc.)
        await handleFailedMessage(message, error)
      }
    },
  })
}
```

### Consumer Best Practices

1. **Consumer Groups**: Use consumer groups for parallel processing
2. **At-Least-Once Delivery**: Handle idempotent processing
3. **Error Handling**: Implement retry logic and dead letter queue
4. **Offset Management**: Commit offsets after successful processing
5. **Graceful Shutdown**: Handle SIGTERM/SIGINT signals

### Graceful Shutdown

```typescript
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully')
  await consumer.disconnect()
  await producer.disconnect()
  process.exit(0)
})
```

## Error Handling

### Retry Logic

```typescript
// src/utils/retry.ts
export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  initialDelay = 1000
): Promise<T> {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn()
    } catch (error) {
      if (attempt === maxRetries) throw error

      const delay = initialDelay * Math.pow(2, attempt)
      logger.warn(`Retry attempt ${attempt + 1}/${maxRetries}, waiting ${delay}ms`)
      await sleep(delay)
    }
  }
  throw new Error('Max retries exceeded')
}
```

### Dead Letter Queue

```typescript
async function handleFailedMessage(message: KafkaMessage, error: Error) {
  // Send to dead letter queue after max retries
  await producer.send({
    topic: 'dead-letter-queue',
    messages: [
      {
        value: message.value,
        headers: {
          ...message.headers,
          'original-topic': TOPICS.USER_EVENTS,
          'error-message': error.message,
          'failed-at': new Date().toISOString(),
        },
      },
    ],
  })
}
```

## Environment Variables

```bash
# Message Broker
KAFKA_BROKERS=[localhost:9092]              # Comma-separated list
KAFKA_CLIENT_ID=[user-service]
KAFKA_GROUP_ID=[user-event-processor]

# Or for RabbitMQ
RABBITMQ_URL=[amqp://localhost:5672]

# Configuration
MESSAGE_RETENTION_MS=[604800000]            # 7 days in milliseconds
CONSUMER_SESSION_TIMEOUT=[30000]            # 30 seconds
MAX_POLL_INTERVAL=[300000]                  # 5 minutes

# Dead Letter Queue
DLQ_ENABLED=[true]
DLQ_TOPIC=[dead-letter-queue]

# Monitoring
ENABLE_METRICS=[true]
METRICS_PORT=[9090]
```

## Testing

### Unit Tests

```typescript
describe('handleUserCreated', () => {
  it('processes user.created event', async () => {
    const event: UserCreatedEvent = {
      eventId: '123',
      eventType: 'user.created',
      timestamp: new Date().toISOString(),
      data: { userId: 'user-123', email: 'test@example.com', name: 'Test' },
      metadata: { version: '1.0.0', source: 'user-service' },
    }

    await handleUserCreated(event)

    // Verify side effects
    expect(mockDatabase.saveUser).toHaveBeenCalledWith(event.data)
  })
})
```

### Integration Tests

```typescript
describe('UserEventConsumer (integration)', () => {
  beforeAll(async () => {
    // Start test Kafka instance
    await testKafka.start()
  })

  it('consumes and processes messages', async () => {
    const testProducer = testKafka.producer()
    const event = createTestUserEvent()

    await testProducer.send({
      topic: TOPICS.USER_EVENTS,
      messages: [{ value: JSON.stringify(event) }],
    })

    // Wait for processing
    await waitFor(() => {
      expect(processedEvents).toContain(event.eventId)
    })
  })
})
```

## Monitoring

### Metrics

Key metrics to monitor:

- **Message Throughput**: Messages/second produced and consumed
- **Consumer Lag**: Offset lag per partition
- **Processing Time**: Time to process each message
- **Error Rate**: Failed messages/total messages
- **Dead Letter Queue Size**: Number of failed messages

### Health Checks

```typescript
// Health check endpoint
app.get('/health', async (req, res) => {
  const lag = await getConsumerLag()
  const isHealthy = lag.every((partition) => partition.lag < 1000)

  res.status(isHealthy ? 200 : 503).json({
    status: isHealthy ? 'healthy' : 'unhealthy',
    consumerLag: lag,
    timestamp: new Date().toISOString(),
  })
})
```

## Deployment

### Docker Compose (Development)

```yaml
# docker-compose.yml
services:
  kafka:
    image: confluentinc/cp-kafka:latest
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092

  consumer:
    build: .
    command: npm run consumer
    depends_on:
      - kafka
    environment:
      KAFKA_BROKERS: kafka:9092
```

### Production

- **Scaling**: Run multiple consumer instances (consumer group handles load balancing)
- **Monitoring**: Use [Prometheus + Grafana / Datadog]
- **Alerting**: Alert on high consumer lag, error rates

## Troubleshooting

**Issue**: Consumer lag increasing

**Solution**:
1. Check consumer processing time
2. Increase number of consumer instances
3. Optimize message handlers
4. Increase partition count (requires rebalancing)

---

**Issue**: Messages not being consumed

**Solution**:
```bash
# Check consumer group status
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group user-event-processor --describe

# Reset consumer offsets (development only!)
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group user-event-processor --reset-offsets --to-earliest --execute --all-topics
```

## Best Practices

1. **Idempotency**: Design handlers to be idempotent (can process same message multiple times safely)
2. **Schema Evolution**: Version your message schemas
3. **Monitoring**: Always monitor consumer lag
4. **Error Handling**: Implement dead letter queue for failed messages
5. **Testing**: Test with real message broker in integration tests
6. **Documentation**: Document message schemas and event types
