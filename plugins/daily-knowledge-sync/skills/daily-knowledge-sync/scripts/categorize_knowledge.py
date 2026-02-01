#!/usr/bin/env python3
"""
Categorize knowledge items into appropriate directories.
"""

import re
import yaml
from pathlib import Path
from typing import Any


def _load_category_keywords():
    """Load category keywords from config file."""
    script_dir = Path(__file__).parent
    config_path = script_dir.parent / "config" / "categories.yaml"

    with open(config_path) as f:
        config = yaml.safe_load(f)

    # Convert config to keyword dict
    keywords = {}
    for cat_name, cat_config in config["categories"].items():
        keywords[cat_name] = cat_config["keywords"]

    return keywords, config.get("default_category", "domain")


# Category keywords for automatic classification (loaded from config)
CATEGORY_KEYWORDS, DEFAULT_CATEGORY = _load_category_keywords()


class KnowledgeCategorizer:
    """Categorize knowledge items into directories."""

    def __init__(self, repo_path: str):
        """
        Initialize categorizer.

        Args:
            repo_path: Path to knowledge repository
        """
        self.repo_path = Path(repo_path).expanduser()
        self._ensure_category_dirs()

    def _ensure_category_dirs(self):
        """Create category directories if they don't exist."""
        for category in CATEGORY_KEYWORDS.keys():
            category_dir = self.repo_path / category
            category_dir.mkdir(parents=True, exist_ok=True)

            # Create README if doesn't exist
            readme = category_dir / "README.md"
            if not readme.exists():
                readme.write_text(f"# {category.title()}\n\n", encoding="utf-8")

    def categorize(self, text: str, tags: list[str] | None = None) -> str:
        """
        Determine the best category for a knowledge item.

        Args:
            text: Knowledge item text
            tags: Optional list of tags

        Returns:
            str: Category name
        """
        text_lower = text.lower()
        scores = {}

        # Score each category based on keyword matches
        for category, keywords in CATEGORY_KEYWORDS.items():
            score = 0
            for keyword in keywords:
                if keyword in text_lower:
                    score += text_lower.count(keyword)
            scores[category] = score

        # Check tags if provided
        if tags:
            for tag in tags:
                tag_lower = tag.lower()
                for category, keywords in CATEGORY_KEYWORDS.items():
                    if tag_lower in keywords or category in tag_lower:
                        scores[category] += 5  # Tag matches get higher weight

        # Return category with highest score, or default category
        if max(scores.values()) > 0:
            return max(scores, key=scores.get)
        else:
            return DEFAULT_CATEGORY

    def generate_filename(
        self, title: str, date: str, provided_filename: str | None = None
    ) -> str:
        """
        Generate a filename from title and date.

        Args:
            title: Knowledge item title
            date: Date in YYYY-MM-DD format
            provided_filename: Optional kebab-case English filename (without date/extension)

        Returns:
            str: Filename (e.g., "2026-01-31_fix-import-error.md")
        """
        if provided_filename:
            # 提供されたファイル名を使用（kebab-case、英語）
            clean_title = re.sub(r"[^a-z0-9-]", "", provided_filename.lower())
            clean_title = re.sub(r"-+", "-", clean_title).strip("-")
        else:
            # フォールバック: ASCII文字のみ + kebab-case
            clean_title = re.sub(r"[^\x00-\x7F]+", "", title)
            clean_title = clean_title.lower()
            clean_title = re.sub(r"[^\w\s-]", "", clean_title)
            clean_title = re.sub(r"[\s_]+", "-", clean_title)
            clean_title = re.sub(r"-+", "-", clean_title).strip("-")

        clean_title = clean_title[:50]
        if not clean_title:
            clean_title = "untitled"

        return f"{date}_{clean_title}.md"

    def create_knowledge_file(
        self,
        category: str,
        filename: str,
        title: str,
        content: str,
        tags: list[str] | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> Path:
        """
        Create a knowledge markdown file in the appropriate category.

        Args:
            category: Category name
            filename: Filename (without path)
            title: Knowledge title
            content: Knowledge content
            tags: Optional list of tags
            metadata: Optional metadata dict

        Returns:
            Path: Path to created file
        """
        category_dir = self.repo_path / category
        file_path = category_dir / filename

        # Build frontmatter
        frontmatter = ["---"]
        frontmatter.append(f"title: {title}")
        frontmatter.append(f"category: {category}")

        if tags:
            tags_str = ", ".join(tags)
            frontmatter.append(f"tags: [{tags_str}]")

        if metadata:
            for key, value in metadata.items():
                if isinstance(value, str):
                    frontmatter.append(f"{key}: {value}")
                else:
                    frontmatter.append(f"{key}: {value}")

        frontmatter.append("---")
        frontmatter.append("")

        # Build content
        full_content = "\n".join(frontmatter) + f"\n# {title}\n\n{content}\n"

        file_path.write_text(full_content, encoding="utf-8")
        return file_path


def main():
    """CLI interface for testing."""
    import sys

    if len(sys.argv) < 4:
        print("Usage:")
        print(
            "  python categorize_knowledge.py <repo_path> <title> <content> [tags...]"
        )
        sys.exit(1)

    repo_path = sys.argv[1]
    title = sys.argv[2]
    content = sys.argv[3]
    tags = sys.argv[4:] if len(sys.argv) > 4 else None

    categorizer = KnowledgeCategorizer(repo_path)

    # Categorize
    category = categorizer.categorize(content, tags)
    print(f"Category: {category}")

    # Generate filename
    from datetime import datetime

    date = datetime.now().strftime("%Y-%m-%d")
    filename = categorizer.generate_filename(title, date)
    print(f"Filename: {filename}")

    # Create file
    file_path = categorizer.create_knowledge_file(
        category=category,
        filename=filename,
        title=title,
        content=content,
        tags=tags,
        metadata={"date": date},
    )

    print(f"✅ Created: {file_path}")


if __name__ == "__main__":
    main()
