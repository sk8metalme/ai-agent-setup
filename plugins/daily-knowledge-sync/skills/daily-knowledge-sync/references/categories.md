# Knowledge Categories

This document defines the knowledge categorization system.

## Category Structure

The knowledge repository uses a category-based directory structure with tagged markdown files:

```
knowledge-repo/
├── errors/          # Error resolutions and bug fixes
├── patterns/        # Coding patterns and best practices
├── commands/        # Useful commands and CLI tools
├── design/          # Architecture and design decisions
├── domain/          # Domain-specific knowledge
└── operations/      # DevOps, maintenance, and operations
```

Each category contains markdown files with frontmatter tags for cross-category searchability.

## Category Definitions

### errors/

**Purpose**: Document error resolutions and debugging approaches

**Content Types**:
- Error messages and their solutions
- Bug fix procedures
- Debugging techniques
- Common pitfalls and how to avoid them

**Examples**:
- "Fix ModuleNotFoundError in Python imports"
- "Resolve CORS error in FastAPI"
- "Debug memory leak in Node.js application"

**Keywords**: error, exception, bug, fix, resolve, debug, traceback

---

### patterns/

**Purpose**: Document coding patterns, best practices, and implementation approaches

**Content Types**:
- Design patterns
- Implementation strategies
- Code organization techniques
- Refactoring approaches
- Architecture patterns

**Examples**:
- "Repository pattern for database access"
- "Use dependency injection for testability"
- "Implement circuit breaker for resilience"

**Keywords**: pattern, implementation, approach, best practice, design, architecture, refactor

---

### commands/

**Purpose**: Document useful commands, CLI tools, and shell scripts

**Content Types**:
- Bash/shell commands
- Git workflows
- Docker commands
- Package manager usage
- Tool configurations

**Examples**:
- "Use git rebase --onto for branch management"
- "Find and delete files older than 30 days"
- "Docker multi-stage build optimization"

**Keywords**: command, cli, bash, shell, terminal, git, npm, docker, script

---

### design/

**Purpose**: Document architecture decisions and system design

**Content Types**:
- Architecture diagrams
- Design decisions and rationale
- System design patterns
- Data modeling
- API design

**Examples**:
- "Microservices vs. monolith trade-offs"
- "Event-driven architecture for async processing"
- "Database schema design for multi-tenancy"

**Keywords**: design, architecture, diagram, model, system, c4, sequence, mermaid

---

### domain/

**Purpose**: Document domain-specific knowledge and business logic

**Content Types**:
- Business rules
- Domain workflows
- Industry-specific knowledge
- Regulatory requirements
- Product specifications

**Examples**:
- "Payment processing workflow"
- "User authentication flow"
- "Compliance requirements for GDPR"

**Keywords**: domain, business, requirement, specification, workflow, process, rule

---

### operations/

**Purpose**: Document DevOps, maintenance, and operational procedures

**Content Types**:
- Deployment procedures
- Monitoring setup
- Incident response
- Maintenance tasks
- CI/CD pipelines
- Infrastructure management

**Examples**:
- "Blue-green deployment strategy"
- "Set up Prometheus monitoring"
- "Database backup and restore procedure"

**Keywords**: deploy, deployment, maintenance, operation, monitoring, ci/cd, devops, infrastructure

## Categorization Guidelines

### Primary Category Selection

Choose the category that best represents the **primary purpose** of the knowledge:

- If it's primarily about fixing an error → `errors/`
- If it's primarily about how to implement something → `patterns/`
- If it's primarily a command or tool usage → `commands/`
- If it's primarily about system design → `design/`
- If it's primarily business/domain logic → `domain/`
- If it's primarily operational/DevOps → `operations/`

### Handling Overlaps

Many knowledge items span multiple categories. Use:

1. **Primary category** for directory placement
2. **Tags** for cross-category discoverability

Example: "Deploy FastAPI with Docker"
- Primary category: `operations/` (deployment focus)
- Tags: `[docker, fastapi, deployment, commands, devops]`

This makes it discoverable when searching for Docker commands or FastAPI patterns.

### Category Migration

Knowledge items may be recategorized if:
- The original categorization was unclear
- The knowledge evolved to fit better elsewhere
- Usage patterns show it's searched for differently

Migration process:
1. Move file to new category directory
2. Update frontmatter `category` field
3. Add redirect or note in original location if needed

## Automatic Categorization

The `categorize_knowledge.py` script uses keyword scoring to suggest categories.

**How it works**:
1. Scans text for category keywords
2. Counts keyword matches per category
3. Considers tags with higher weight
4. Selects category with highest score
5. Falls back to `domain/` if no clear match

**Override automatic categorization** by manually specifying category in frontmatter.

## Search Strategy

### Finding Knowledge Across Categories

Use a combination of:

1. **Category browsing**: Start with the most relevant category directory
2. **Tag search**: Search for tags across all categories
3. **Full-text search**: Use `grep` or repository search for keywords
4. **Related links**: Follow "Related" sections in knowledge files

Example search workflows:

**Finding error solutions**:
```bash
# Browse errors directory
ls errors/

# Search for specific error
grep -r "ModuleNotFoundError" errors/

# Search across all categories with tag
grep -r "tags: \[.*python.*import.*\]" .
```

**Finding implementation patterns**:
```bash
# Browse patterns directory
ls patterns/

# Search for authentication patterns
grep -r "authentication" patterns/ design/

# Find by tags
grep -r "tags: \[.*authentication.*security.*\]" .
```

## Best Practices

1. **Choose one primary category** - Don't duplicate files across categories
2. **Use tags liberally** - Helps with cross-category discovery
3. **Link related knowledge** - Build a knowledge graph
4. **Keep categories balanced** - If one grows too large, consider subcategories
5. **Review and refactor** - Periodically review categorization accuracy
