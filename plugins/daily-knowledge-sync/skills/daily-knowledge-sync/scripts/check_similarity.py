#!/usr/bin/env python3
"""
Check similarity between knowledge items to detect duplicates.
Uses TF-IDF and cosine similarity for text comparison.
"""

import json
from pathlib import Path
from typing import Any

try:
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.metrics.pairwise import cosine_similarity

    SKLEARN_AVAILABLE = True
except ImportError:
    SKLEARN_AVAILABLE = False


class SimilarityChecker:
    """Check similarity between knowledge items."""

    def __init__(self, threshold: float = 0.7):
        """
        Initialize similarity checker.

        Args:
            threshold: Similarity threshold (0.0-1.0). Items above this are considered duplicates.
        """
        self.threshold = threshold

        if not SKLEARN_AVAILABLE:
            print(
                "Warning: scikit-learn not available. Using fallback simple matching."
            )

    def calculate_similarity(self, text1: str, text2: str) -> float:
        """
        Calculate similarity between two texts.

        Args:
            text1: First text
            text2: Second text

        Returns:
            float: Similarity score (0.0-1.0)
        """
        if not text1 or not text2:
            return 0.0

        if SKLEARN_AVAILABLE:
            return self._tfidf_similarity(text1, text2)
        else:
            return self._simple_similarity(text1, text2)

    def _tfidf_similarity(self, text1: str, text2: str) -> float:
        """Calculate TF-IDF based cosine similarity."""
        vectorizer = TfidfVectorizer(lowercase=True, stop_words="english")
        try:
            tfidf_matrix = vectorizer.fit_transform([text1, text2])
            similarity = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:2])[0][0]
            return float(similarity)
        except Exception:
            return self._simple_similarity(text1, text2)

    def _simple_similarity(self, text1: str, text2: str) -> float:
        """Fallback simple word-based similarity."""
        words1 = set(text1.lower().split())
        words2 = set(text2.lower().split())

        if not words1 or not words2:
            return 0.0

        intersection = words1 & words2
        union = words1 | words2

        return len(intersection) / len(union)

    def find_duplicates(
        self, new_item: str, existing_items: list[str]
    ) -> list[tuple[int, float]]:
        """
        Find duplicates of new_item in existing_items.

        Args:
            new_item: New knowledge item text
            existing_items: List of existing knowledge item texts

        Returns:
            list[tuple[int, float]]: List of (index, similarity_score) for duplicates above threshold
        """
        duplicates = []

        for idx, existing_item in enumerate(existing_items):
            similarity = self.calculate_similarity(new_item, existing_item)
            if similarity >= self.threshold:
                duplicates.append((idx, similarity))

        return sorted(duplicates, key=lambda x: x[1], reverse=True)

    def check_knowledge_file(
        self, new_text: str, knowledge_file: Path
    ) -> list[dict[str, Any]]:
        """
        Check for duplicates in a markdown knowledge file.

        Args:
            new_text: New knowledge text to check
            knowledge_file: Path to existing markdown file

        Returns:
            list[dict]: List of duplicate matches with line numbers and scores
        """
        if not knowledge_file.exists():
            return []

        content = knowledge_file.read_text(encoding="utf-8")
        sections = self._split_markdown_sections(content)

        duplicates = []
        for section in sections:
            similarity = self.calculate_similarity(new_text, section["text"])
            if similarity >= self.threshold:
                duplicates.append(
                    {
                        "file": str(knowledge_file),
                        "section": section["title"],
                        "similarity": similarity,
                        "text_preview": section["text"][:200] + "...",
                    }
                )

        return sorted(duplicates, key=lambda x: x["similarity"], reverse=True)

    def _split_markdown_sections(self, content: str) -> list[dict[str, str]]:
        """Split markdown content into sections by headers."""
        sections = []
        current_section = {"title": "Intro", "text": ""}

        for line in content.split("\n"):
            if line.startswith("#"):
                if current_section["text"].strip():
                    sections.append(current_section)
                current_section = {"title": line.strip("# ").strip(), "text": ""}
            else:
                current_section["text"] += line + "\n"

        if current_section["text"].strip():
            sections.append(current_section)

        return sections


def main():
    """CLI interface for testing."""
    import sys

    if len(sys.argv) < 3:
        print("Usage:")
        print("  python check_similarity.py <text1> <text2>")
        print("  python check_similarity.py <new_text> --file <knowledge_file.md>")
        sys.exit(1)

    checker = SimilarityChecker(threshold=0.7)

    if "--file" in sys.argv:
        new_text = sys.argv[1]
        file_idx = sys.argv.index("--file")
        knowledge_file = Path(sys.argv[file_idx + 1])

        print(f"Checking against: {knowledge_file}")
        duplicates = checker.check_knowledge_file(new_text, knowledge_file)

        if duplicates:
            print(f"\n⚠️  Found {len(duplicates)} potential duplicates:")
            for dup in duplicates:
                print(f"  - {dup['section']}: {dup['similarity']:.2%} similar")
        else:
            print("✅ No duplicates found")

    else:
        text1 = sys.argv[1]
        text2 = sys.argv[2]

        similarity = checker.calculate_similarity(text1, text2)
        print(f"Similarity: {similarity:.2%}")

        if similarity >= 0.7:
            print("⚠️  Potentially duplicate")
        else:
            print("✅ Not duplicate")


if __name__ == "__main__":
    main()
