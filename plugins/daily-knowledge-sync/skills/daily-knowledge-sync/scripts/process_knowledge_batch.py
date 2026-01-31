#!/usr/bin/env python3
"""
Process knowledge candidates in batch.

1. Load candidates from JSON file
2. Evaluate using KnowledgeEvaluator
3. Check similarity with existing knowledge
4. Categorize and create knowledge files
5. Commit to GitHub repository
"""

import json
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Any

from categorize_knowledge import KnowledgeCategorizer
from check_similarity import SimilarityChecker
from evaluate_knowledge import KnowledgeEvaluator


class KnowledgeBatchProcessor:
    """Process knowledge candidates in batch."""

    def __init__(
        self,
        repo_path: str,
        similarity_threshold: float = 0.7,
        dry_run: bool = False,
    ):
        """
        Initialize batch processor.

        Args:
            repo_path: Path to knowledge repository
            similarity_threshold: Threshold for similarity checking (0.0-1.0)
            dry_run: If True, don't actually create files or commit
        """
        self.repo_path = Path(repo_path).expanduser()
        self.similarity_threshold = similarity_threshold
        self.dry_run = dry_run

        self.evaluator = KnowledgeEvaluator()
        self.categorizer = KnowledgeCategorizer(str(self.repo_path))
        self.similarity_checker = SimilarityChecker(threshold=similarity_threshold)

    def process_candidates(
        self, candidates_file: Path, date: str | None = None
    ) -> dict[str, Any]:
        """
        Process all candidates from a JSON file.

        Args:
            candidates_file: Path to JSON file with candidates
            date: Date string (YYYY-MM-DD), defaults to today

        Returns:
            dict: Processing statistics
        """
        if date is None:
            date = datetime.now().strftime("%Y-%m-%d")

        # Load candidates
        with open(candidates_file) as f:
            candidates = json.load(f)

        print(f"Processing {len(candidates)} candidates for {date}...")
        print()

        stats = {
            "total": len(candidates),
            "accepted": 0,
            "rejected": 0,
            "duplicates": 0,
            "created": 0,
        }

        created_files = []

        for i, candidate in enumerate(candidates, 1):
            print(f"[{i}/{len(candidates)}] ", end="")

            # 1. Evaluate
            result = self.evaluator.evaluate(candidate)

            if result.category != "accept":
                print(f"❌ Rejected (score: {result.score})")
                if result.excluded_by:
                    print(f"   Reason: {result.excluded_by}")
                stats["rejected"] += 1
                continue

            stats["accepted"] += 1
            print(f"✅ Accepted (score: {result.score})")

            # 2. Check similarity
            text = candidate.get("text", "")
            similar = self._find_similar_knowledge(text)

            if similar:
                print(f"   ⚠️  Similar to: {similar[0]['file']}")
                stats["duplicates"] += 1
                continue

            # 3. Categorize
            category = self.categorizer.categorize(text)
            print(f"   Category: {category}")

            # 4. Generate title (first line or first 50 chars)
            title = self._generate_title(text)
            print(f"   Title: {title}")

            # 5. Create file
            if not self.dry_run:
                filename = self.categorizer.generate_filename(title, date)
                file_path = self.categorizer.create_knowledge_file(
                    category=category,
                    filename=filename,
                    title=title,
                    content=text,
                    tags=self._extract_tags(category, text),
                    metadata={
                        "date": date,
                        "score": result.score,
                        "source_file": candidate.get("source_file", ""),
                    },
                )
                print(f"   📝 Created: {file_path.relative_to(self.repo_path)}")
                created_files.append(file_path)
                stats["created"] += 1
            else:
                print("   📝 Would create file (dry run)")

            print()

        # 6. Commit to git
        if created_files and not self.dry_run:
            self._commit_to_git(created_files, date)

        return stats

    def _generate_title(self, text: str, max_length: int = 60) -> str:
        """
        Generate a title from text.

        Args:
            text: Text content
            max_length: Maximum title length

        Returns:
            str: Generated title
        """
        # Try to use first line
        first_line = text.split("\n")[0].strip()

        # Remove markdown formatting
        first_line = first_line.lstrip("#").strip()

        # Limit length
        if len(first_line) > max_length:
            first_line = first_line[:max_length].rsplit(" ", 1)[0] + "..."

        return first_line if first_line else "Knowledge item"

    def _extract_tags(self, category: str, text: str) -> list[str]:
        """
        Extract relevant tags from text.

        Args:
            category: Primary category
            text: Text content

        Returns:
            list[str]: List of tags
        """
        tags = [category]

        # Common technical keywords
        keywords = {
            "python": "python",
            "javascript": "javascript",
            "typescript": "typescript",
            "java": "java",
            "docker": "docker",
            "kubernetes": "kubernetes",
            "git": "git",
            "api": "api",
            "database": "database",
            "security": "security",
            "performance": "performance",
            "test": "testing",
            "debug": "debugging",
        }

        text_lower = text.lower()
        for keyword, tag in keywords.items():
            if keyword in text_lower and tag not in tags:
                tags.append(tag)

        return tags[:5]  # Limit to 5 tags

    def _find_similar_knowledge(self, text: str) -> list[dict]:
        """
        Find similar knowledge in the repository.

        Args:
            text: Text to check for similarity

        Returns:
            list[dict]: List of similar knowledge items (empty if none found)
        """
        # Check all categories
        categories = ["errors", "ops", "domain", "knowledge"]
        all_duplicates = []

        for category in categories:
            category_dir = self.repo_path / category
            if not category_dir.exists():
                continue

            # Check each markdown file in the category
            for md_file in category_dir.glob("*.md"):
                duplicates = self.similarity_checker.check_knowledge_file(text, md_file)
                if duplicates:
                    all_duplicates.extend(duplicates)

        # Return sorted by similarity (highest first)
        return sorted(all_duplicates, key=lambda x: x["similarity"], reverse=True)

    def _commit_to_git(self, files: list[Path], date: str):
        """
        Commit files to git repository.

        Args:
            files: List of file paths to commit
            date: Date string for commit message
        """
        try:
            # Change to repo directory
            original_dir = Path.cwd()
            import os

            os.chdir(self.repo_path)

            # Git add
            for file in files:
                subprocess.run(
                    ["git", "add", str(file.relative_to(self.repo_path))],
                    check=True,
                )

            # Git commit
            commit_msg = f"Add knowledge from {date}\n\nAuto-generated by daily-knowledge-sync"
            subprocess.run(
                ["git", "commit", "-m", commit_msg],
                check=True,
            )

            print(f"✅ Committed {len(files)} files to git")

            # Return to original directory
            os.chdir(original_dir)

        except subprocess.CalledProcessError as e:
            print(f"❌ Git commit failed: {e}")
        except Exception as e:
            print(f"❌ Error during git commit: {e}")


def main():
    """CLI interface."""
    import sys

    if len(sys.argv) < 3:
        print("Usage:")
        print(
            "  python process_knowledge_batch.py <candidates_json> <repo_path> [--dry-run] [--date YYYY-MM-DD]"
        )
        print()
        print("Example:")
        print(
            "  python process_knowledge_batch.py /tmp/knowledge_candidates_2026-01-31.json ~/worklog"
        )
        sys.exit(1)

    candidates_file = Path(sys.argv[1])
    repo_path = sys.argv[2]

    # Parse optional arguments
    dry_run = "--dry-run" in sys.argv
    date = None
    if "--date" in sys.argv:
        date_idx = sys.argv.index("--date") + 1
        if date_idx < len(sys.argv):
            date = sys.argv[date_idx]

    # Process
    processor = KnowledgeBatchProcessor(repo_path, dry_run=dry_run)
    stats = processor.process_candidates(candidates_file, date)

    # Print summary
    print("=" * 50)
    print("SUMMARY")
    print("=" * 50)
    print(f"Total candidates: {stats['total']}")
    print(f"  ✅ Accepted:  {stats['accepted']}")
    print(f"  ❌ Rejected:  {stats['rejected']}")
    print(f"  ⚠️  Duplicates: {stats['duplicates']}")
    print(f"  📝 Created:   {stats['created']}")
    print()

    if dry_run:
        print("(Dry run - no files were actually created)")


if __name__ == "__main__":
    main()
