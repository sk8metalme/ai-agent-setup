#!/usr/bin/env python3
"""Create knowledge files from Claude Code evaluation results."""

import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).parent
sys.path.insert(0, str(SCRIPT_DIR))

from categorize_knowledge import KnowledgeCategorizer
from check_similarity import SimilarityChecker

# Pattern for sanitizing filenames
INVALID_FILENAME_CHARS = re.compile(r'[/\\:*?"<>|]')


class KnowledgeFileCreator:
    """Create knowledge files from evaluation results."""

    def __init__(self, repo_path: str):
        """
        Initialize file creator.

        Args:
            repo_path: Path to knowledge repository
        """
        self.repo_path = Path(repo_path).expanduser()
        self.categorizer = KnowledgeCategorizer(str(self.repo_path))
        self.similarity_checker = SimilarityChecker(threshold=0.7)

    def create_files(
        self,
        candidates_file: Path,
        evaluation_file: Path,
        date: str,
    ) -> dict[str, Any]:
        """
        Create knowledge files from evaluation results.

        Args:
            candidates_file: Path to candidates JSON file
            evaluation_file: Path to evaluation results JSON file
            date: Date string (YYYY-MM-DD)

        Returns:
            dict: Statistics about created files
        """
        # Load candidates
        with open(candidates_file) as f:
            candidates = json.load(f)

        # Load evaluation results
        with open(evaluation_file) as f:
            evaluations = json.load(f)

        # Create mapping of index to candidate
        candidate_map = {i: candidate for i, candidate in enumerate(candidates)}

        # Process only accepted items
        stats = {
            "total": len(evaluations),
            "accepted": 0,
            "rejected": 0,
            "duplicates": 0,
            "created": 0,
            "by_category": {},
        }

        created_files = []

        for evaluation in evaluations:
            if evaluation["decision"] == "reject":
                stats["rejected"] += 1
                continue

            stats["accepted"] += 1
            index = evaluation.get("index")
            if index is None or index not in candidate_map:
                print(f"Warning: Invalid index {index}")
                continue

            candidate = candidate_map[index]
            category = evaluation["category"]
            title = evaluation["title"]
            text = candidate["text"]

            # Check similarity with existing knowledge
            if self._is_duplicate(text, category):
                stats["duplicates"] += 1
                print(f"⏭️  Skipped duplicate: {title}")
                continue

            # Create knowledge file
            file_path = self._create_knowledge_file(
                category=category,
                title=title,
                text=text,
                timestamp=candidate["timestamp"],
                project_path=candidate.get("project_path", ""),
            )

            if file_path:
                created_files.append(file_path)
                stats["created"] += 1
                stats["by_category"][category] = stats["by_category"].get(category, 0) + 1
                print(f"✅ Created: {file_path.relative_to(self.repo_path)}")

        # Commit to git if files were created
        if created_files:
            self._git_commit(created_files, date)

        return stats

    def _is_duplicate(self, text: str, category: str) -> bool:
        """
        Check if text is similar to existing knowledge in the category.

        Args:
            text: Text to check
            category: Category directory

        Returns:
            bool: True if duplicate found
        """
        category_dir = self.repo_path / category
        if not category_dir.exists():
            return False

        for existing_file in category_dir.glob("*.md"):
            try:
                existing_text = existing_file.read_text(encoding="utf-8")
                similarity = self.similarity_checker.calculate_similarity(
                    text, existing_text
                )
                if similarity >= self.similarity_checker.threshold:
                    return True
            except Exception as e:
                print(f"Warning: Error reading {existing_file}: {e}")
                continue

        return False

    def _create_knowledge_file(
        self,
        category: str,
        title: str,
        text: str,
        timestamp: str,
        project_path: str = "",
    ) -> Path | None:
        """
        Create a knowledge markdown file.

        Args:
            category: Category directory name
            title: Knowledge title
            text: Knowledge content
            timestamp: ISO timestamp
            project_path: Project path (optional)

        Returns:
            Path | None: Created file path or None on error
        """
        category_dir = self.repo_path / category
        category_dir.mkdir(parents=True, exist_ok=True)

        # Generate filename from title
        filename = self._sanitize_filename(title) + ".md"
        file_path = category_dir / filename

        # Avoid overwriting existing files
        if file_path.exists():
            # Add timestamp suffix
            dt = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
            timestamp_suffix = dt.strftime("%Y%m%d_%H%M%S")
            filename = f"{self._sanitize_filename(title)}_{timestamp_suffix}.md"
            file_path = category_dir / filename

        # Create markdown content
        content = f"# {title}\n\n"
        if project_path:
            content += f"**プロジェクト**: `{project_path}`\n\n"
        content += f"**日時**: {timestamp}\n\n"
        content += "---\n\n"
        content += text.strip() + "\n"

        try:
            file_path.write_text(content, encoding="utf-8")
            return file_path
        except Exception as e:
            print(f"Error: Failed to create {file_path}: {e}")
            return None

    def _sanitize_filename(self, title: str, max_length: int = 100) -> str:
        """
        Sanitize title for use as filename.

        Args:
            title: Title string
            max_length: Maximum filename length

        Returns:
            str: Sanitized filename (without extension)
        """
        filename = INVALID_FILENAME_CHARS.sub("_", title)
        return filename[:max_length].strip()

    def _git_commit(self, files: list[Path], date: str):
        """
        Commit created files to git repository.

        Args:
            files: List of file paths to commit
            date: Date string for commit message
        """
        try:
            # Change to repo directory
            subprocess.run(
                ["git", "add"] + [str(f.relative_to(self.repo_path)) for f in files],
                cwd=self.repo_path,
                check=True,
            )

            commit_message = f"knowledge: add {len(files)} items from {date}"
            subprocess.run(
                ["git", "commit", "-m", commit_message],
                cwd=self.repo_path,
                check=True,
            )

            print(f"📝 Committed {len(files)} files to git")

        except subprocess.CalledProcessError as e:
            print(f"Warning: Git commit failed: {e}")


def main():
    """CLI interface."""
    if len(sys.argv) < 4:
        print("Usage: python create_knowledge_files.py <candidates.json> <evaluations.json> <repo_path> [date]")
        sys.exit(1)

    candidates_file = Path(sys.argv[1])
    evaluation_file = Path(sys.argv[2])
    repo_path = sys.argv[3]

    if len(sys.argv) >= 5:
        date = sys.argv[4]
    else:
        date = datetime.now().strftime("%Y-%m-%d")

    if not candidates_file.exists():
        print(f"Error: Candidates file not found: {candidates_file}")
        sys.exit(1)

    if not evaluation_file.exists():
        print(f"Error: Evaluation file not found: {evaluation_file}")
        sys.exit(1)

    print(f"Creating knowledge files for: {date}")
    print(f"  Candidates: {candidates_file}")
    print(f"  Evaluations: {evaluation_file}")
    print(f"  Repository: {repo_path}")

    creator = KnowledgeFileCreator(repo_path)
    stats = creator.create_files(candidates_file, evaluation_file, date)

    print("\n=== Statistics ===")
    print(f"Total evaluated: {stats['total']}")
    print(f"Accepted: {stats['accepted']}")
    print(f"Rejected: {stats['rejected']}")
    print(f"Duplicates: {stats['duplicates']}")
    print(f"Created: {stats['created']}")
    print("\nBy category:")
    for category, count in stats["by_category"].items():
        print(f"  {category}: {count}")


if __name__ == "__main__":
    main()
