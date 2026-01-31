# Knowledge File Format

This document defines the format for knowledge markdown files.

## File Structure

Each knowledge file should follow this structure:

```markdown
---
title: Knowledge Title
category: errors|patterns|commands|design|domain|operations
tags: [tag1, tag2, tag3]
date: YYYY-MM-DD
source: conversation|manual|import
---

# Knowledge Title

## Context

Brief context about when/why this knowledge was encountered.

## Problem/Topic

Description of the problem or topic.

## Solution/Insight

The actual knowledge content:
- Key insights
- Solution steps
- Code examples
- Command examples

## Related

- Links to related knowledge items
- References to documentation
```

## Frontmatter Fields

### Required Fields

- **title**: Clear, descriptive title (50-100 chars)
- **category**: One of: errors, patterns, commands, design, domain, operations
- **tags**: Array of relevant tags for searchability
- **date**: Date of creation (YYYY-MM-DD)

### Optional Fields

- **source**: Origin of knowledge (conversation, manual, import)
- **language**: Programming language if applicable
- **framework**: Framework/library if applicable
- **difficulty**: beginner, intermediate, advanced
- **priority**: low, medium, high, critical

## Content Guidelines

### Title

- Be specific and searchable
- Include key terms (error names, command names, etc.)
- Examples:
  - ✅ "Fix ModuleNotFoundError when importing local packages"
  - ✅ "Use git rebase --onto for advanced branch management"
  - ❌ "Error fix"
  - ❌ "Git command"

### Context Section

- When was this encountered?
- What was the broader task?
- Why is this worth documenting?

### Problem/Topic Section

- Clear problem statement or topic description
- Error messages (if applicable)
- Environment details (if relevant)

### Solution/Insight Section

- Step-by-step solution or explanation
- Code examples with syntax highlighting
- Command examples
- Rationale and trade-offs

### Related Section

- Internal links: `[Related knowledge](../errors/2026-01-30_other_error.md)`
- External links: Documentation, Stack Overflow, etc.
- Tags for discoverability

## Tagging Strategy

### Tag Categories

1. **Technology**: `python`, `javascript`, `docker`, `git`, etc.
2. **Domain**: `authentication`, `api`, `database`, `testing`, etc.
3. **Type**: `error-fix`, `best-practice`, `optimization`, `security`, etc.
4. **Complexity**: `beginner`, `advanced`, `quick-fix`, `deep-dive`, etc.

### Tag Best Practices

- Use 3-7 tags per item
- Be consistent with naming (lowercase, hyphenated)
- Include both specific and general tags
- Example: `[python, import-error, package-management, pip, beginner]`

## Examples

### Error Resolution

```markdown
---
title: Fix "Permission denied" error when running Docker without sudo
category: errors
tags: [docker, linux, permissions, sudo, devops]
date: 2026-01-31
source: conversation
---

# Fix "Permission denied" error when running Docker without sudo

## Context

Encountered when trying to run `docker ps` after fresh Docker installation on Ubuntu.

## Problem

Error message:
```
Got permission denied while trying to connect to the Docker daemon socket
```

## Solution

Add user to docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker  # Or logout and login
docker ps      # Should work now
```

## Related

- [Docker installation guide](https://docs.docker.com/engine/install/)
- [Linux user groups](../commands/2026-01-15_linux_groups.md)
```

### Best Practice

```markdown
---
title: Use type hints and Pydantic for API input validation
category: patterns
tags: [python, fastapi, pydantic, validation, type-hints, best-practice]
date: 2026-01-31
source: conversation
difficulty: intermediate
---

# Use type hints and Pydantic for API input validation

## Context

Building REST APIs with FastAPI requires robust input validation.

## Topic

FastAPI + Pydantic provides automatic validation and documentation.

## Insight

Define request models with Pydantic:

```python
from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: str = Field(..., regex=r"^[\w\.-]+@[\w\.-]+\.\w+$")
    age: int = Field(..., ge=0, le=150)

@app.post("/users/")
async def create_user(user: UserCreate):
    return {"username": user.username}
```

Benefits:
- Automatic validation
- Clear error messages
- Auto-generated API docs
- Type safety

## Related

- [FastAPI documentation](https://fastapi.tiangolo.com/)
- [Pydantic models](https://pydantic-docs.helpmanual.io/)
```
