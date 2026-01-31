---
name: daily-knowledge-sync
description: Automatically extract and sync knowledge from daily Claude Code conversations to a GitHub repository. Analyzes JSONL conversation logs, identifies valuable insights (error resolutions, coding patterns, useful commands, design decisions, domain knowledge, operations), checks for duplicates using 70% similarity threshold, and commits to categorized knowledge base. Triggers once per day on first Claude Code startup or with "おはよう" (good morning) greeting.
---

# Daily Knowledge Sync

Automatically harvest knowledge from your Claude Code conversations and build a searchable, categorized knowledge repository.

## Overview

This skill analyzes your previous day's Claude Code conversation logs (JSONL files in `~/.claude/projects/`), extracts valuable knowledge items, categorizes them, checks for duplicates, and commits them to a GitHub repository. It runs once per day on your first Claude Code session.

**What it extracts**:
- Error resolutions and debugging insights
- Coding patterns and best practices
- Useful commands and CLI workflows
- Design decisions and architecture insights
- Domain-specific knowledge
- DevOps and operational procedures

**Key features**:
- 🔄 Automatic daily execution
- 🏷️ Category-based organization + tag metadata
- 🔍 70% similarity threshold for duplicate detection
- 📝 Structured markdown format
- 🔐 Git integration for version control

## Workflow

### Step 1: Check if Should Run Today

First, verify if the skill should run (once per day):

```bash
python scripts/manage_daily_trigger.py check
```

If exit code is 0, proceed. If exit code is 1, skill already ran today.

### Step 2: Configure Repository (First Time Only)

If not already configured, set up the knowledge repository:

**Option A: Use existing repository**

1. Clone your knowledge repo locally:
   ```bash
   git clone <your-knowledge-repo-url> ~/knowledge-base
   ```

2. Note the repository path for later use

**Option B: Create new repository**

1. Create a new GitHub repository (e.g., `my-knowledge-base`)

2. Clone it locally:
   ```bash
   git clone <repo-url> ~/knowledge-base
   ```

3. Initialize structure:
   ```bash
   cd ~/knowledge-base
   mkdir -p errors patterns commands design domain operations
   git add .
   git commit -m "docs: Initialize knowledge base structure"
   git push origin main
   ```

**Configuration variables** (remember these):
- `KNOWLEDGE_REPO_PATH`: Local path to knowledge repo (e.g., `~/knowledge-base`)
- `KNOWLEDGE_REPO_URL`: GitHub repo URL

### Step 3: Extract Knowledge Candidates

Extract potential knowledge items from previous day's JSONL files:

```bash
# Extract for yesterday (default)
python scripts/extract_knowledge.py

# Or specify date
python scripts/extract_knowledge.py 2026-01-30
```

This outputs to `/tmp/knowledge_candidates_YYYY-MM-DD.json`.

**Review the candidates** to understand what was extracted.

### Step 4: Analyze and Synthesize Knowledge

For each candidate in the extracted JSON:

1. **Read the candidate**:
   - `text`: The conversation content
   - `role`: user or assistant
   - `tool_uses`: Tools that were used
   - `errors`: Any error messages

2. **Determine if it's valuable knowledge**:
   - Is it a reusable insight?
   - Does it solve a specific problem?
   - Would you want to reference this in the future?

3. **Synthesize into knowledge format**:
   - Create a clear title
   - Write context section
   - Describe problem/topic
   - Document solution/insight
   - Add related links if applicable

4. **Assign tags**:
   - Technology tags (python, docker, git)
   - Domain tags (api, database, testing)
   - Type tags (error-fix, best-practice)
   - See [references/knowledge_format.md](references/knowledge_format.md) for details

### Step 5: Categorize Knowledge

For each knowledge item, determine category:

```python
from scripts.categorize_knowledge import KnowledgeCategorizer

categorizer = KnowledgeCategorizer(KNOWLEDGE_REPO_PATH)

category = categorizer.categorize(
    text=knowledge_content,
    tags=knowledge_tags
)
```

Categories:
- `errors`: Error resolutions
- `patterns`: Coding patterns and best practices
- `commands`: CLI commands and tools
- `design`: Architecture and design decisions
- `domain`: Business/domain knowledge
- `operations`: DevOps and maintenance

See [references/categories.md](references/categories.md) for categorization guidelines.

### Step 6: Check for Duplicates

Before creating a new knowledge file, check for duplicates:

```python
from scripts.check_similarity import SimilarityChecker

checker = SimilarityChecker(threshold=0.7)

# Check against existing files in category
category_dir = Path(KNOWLEDGE_REPO_PATH) / category
for existing_file in category_dir.glob("*.md"):
    duplicates = checker.check_knowledge_file(
        new_text=knowledge_content,
        knowledge_file=existing_file
    )

    if duplicates:
        # Handle duplicate: skip, merge, or ask user
        print(f"Found similar knowledge: {duplicates[0]['section']}")
```

**Duplicate handling options**:
1. **Skip** if very similar (>90%)
2. **Merge** if complementary (70-90%)
3. **Create new** if sufficiently different (<70%)

### Step 7: Create Knowledge Files

For non-duplicate knowledge:

```python
from datetime import datetime
from scripts.categorize_knowledge import KnowledgeCategorizer

categorizer = KnowledgeCategorizer(KNOWLEDGE_REPO_PATH)
date = datetime.now().strftime("%Y-%m-%d")

filename = categorizer.generate_filename(
    title=knowledge_title,
    date=date
)

file_path = categorizer.create_knowledge_file(
    category=category,
    filename=filename,
    title=knowledge_title,
    content=knowledge_content,
    tags=knowledge_tags,
    metadata={
        "date": date,
        "source": "conversation",
    }
)

print(f"Created: {file_path}")
```

See [references/knowledge_format.md](references/knowledge_format.md) for format details.

### Step 8: Commit and Push to GitHub

After creating all knowledge files:

```bash
cd $KNOWLEDGE_REPO_PATH

# Stage changes
git add errors/ patterns/ commands/ design/ domain/ operations/

# Get username for commit message
USERNAME=$(git config user.name)
DATE=$(date +%Y-%m-%d)

# Commit with standard format
git commit -m "docs: $USERNAME $DATE

Daily knowledge sync from Claude Code conversations.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Push to main branch
git push origin main
```

### Step 9: Mark as Run Today

After successful completion, mark today as processed:

```bash
python scripts/manage_daily_trigger.py mark
```

This prevents the skill from running again until tomorrow.

## Configuration Reference

### Environment Variables (Optional)

You can set these in `~/.bashrc` or `~/.zshrc`:

```bash
export KNOWLEDGE_REPO_PATH="$HOME/knowledge-base"
export KNOWLEDGE_REPO_URL="https://github.com/username/knowledge-base"
export KNOWLEDGE_SIMILARITY_THRESHOLD="0.7"  # Default: 0.7
```

### Skill State Files

- `~/.claude/daily_knowledge/last_run.txt`: Tracks last execution date

### Repository Structure

```
knowledge-base/
├── errors/
│   ├── README.md
│   ├── 2026-01-31_fix_import_error.md
│   └── 2026-01-30_resolve_cors_issue.md
├── patterns/
│   ├── README.md
│   └── 2026-01-31_dependency_injection.md
├── commands/
│   ├── README.md
│   └── 2026-01-31_git_rebase_onto.md
├── design/
│   ├── README.md
│   └── 2026-01-30_microservices_design.md
├── domain/
│   ├── README.md
│   └── 2026-01-29_payment_workflow.md
└── operations/
    ├── README.md
    └── 2026-01-31_docker_deployment.md
```

## Customization

### Adjusting Similarity Threshold

Edit the threshold when creating the SimilarityChecker:

```python
# More strict (fewer duplicates detected)
checker = SimilarityChecker(threshold=0.8)

# More lenient (more duplicates detected)
checker = SimilarityChecker(threshold=0.6)
```

### Custom Categories

Add custom categories by editing `scripts/categorize_knowledge.py`:

```python
CATEGORY_KEYWORDS = {
    # Existing categories...
    "security": ["security", "vulnerability", "auth", "encryption"],
    "performance": ["performance", "optimization", "speed", "memory"],
}
```

Then create the directories in your repository.

### Filtering Conversations

To exclude certain projects from extraction, modify `extract_knowledge.py`:

```python
def find_jsonl_files(self, target_date: str) -> list[Path]:
    jsonl_files = []

    # Skip certain directories
    exclude_dirs = ["test-project", "scratch"]

    for jsonl_file in self.projects_dir.rglob("*.jsonl"):
        if any(excl in str(jsonl_file) for excl in exclude_dirs):
            continue
        jsonl_files.append(jsonl_file)

    return jsonl_files
```

## Troubleshooting

### Skill Runs Multiple Times Per Day

Check trigger state:
```bash
python scripts/manage_daily_trigger.py status
```

Reset if needed:
```bash
rm ~/.claude/daily_knowledge/last_run.txt
```

### No Candidates Extracted

Verify JSONL files exist:
```bash
ls -la ~/.claude/projects/*/
```

Check date format:
```bash
python scripts/extract_knowledge.py 2026-01-31
```

### Similarity Check Not Working

If scikit-learn is not installed:
```bash
pip install scikit-learn
```

The script falls back to simple word-based similarity if scikit-learn is unavailable.

### Git Push Fails

Ensure you're authenticated:
```bash
gh auth status  # For GitHub CLI
# Or configure SSH keys
```

Pull before push if remote has changes:
```bash
cd $KNOWLEDGE_REPO_PATH
git pull origin main --rebase
git push origin main
```

### Categories Not Auto-Detecting

Categories are based on keyword matching. If auto-categorization fails:

1. Check if keywords are in your content
2. Manually specify category when creating file
3. Add custom keywords to `categorize_knowledge.py`

## Best Practices

1. **Review before pushing**: Always review extracted knowledge before committing
2. **Refine titles**: Make titles specific and searchable
3. **Add context**: Include why this knowledge matters
4. **Link related items**: Build connections between knowledge pieces
5. **Use tags generously**: Better over-tagged than under-tagged
6. **Clean up duplicates**: Periodically review for near-duplicates to merge
7. **Update existing knowledge**: Prefer updating existing items over creating duplicates

## Integration with Other Skills

This skill pairs well with:

- **/guardrail-builder**: Auto-create rules from repeated patterns
- **/michi:dev**: Capture development insights during TDD workflow
- **Code Review skills**: Extract review learnings

## Resources

See the bundled reference files for detailed format specifications:

- **[references/knowledge_format.md](references/knowledge_format.md)**: Markdown format, frontmatter, tagging strategy
- **[references/categories.md](references/categories.md)**: Category definitions, classification guidelines, search strategies
