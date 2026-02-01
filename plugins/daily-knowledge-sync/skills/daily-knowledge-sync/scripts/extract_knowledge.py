#!/usr/bin/env python3
"""
Extract potential knowledge items from Claude Code JSONL conversation logs.
"""

import json
import re
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any

# Pre-compiled regex patterns for performance
SYSTEM_MESSAGE_PATTERN = re.compile(r"<system-reminder>|<function_results>")
COMPLETION_PATTERN = re.compile(
    r"^(完了しました|done|finished|completed|✅.*完了)", re.IGNORECASE | re.MULTILINE
)
GREETING_PATTERN = re.compile(
    r"^(なるほど|了解|OK|おはよう|ありがとう)[。！]?$", re.IGNORECASE | re.MULTILINE
)
EXECUTION_LOG_PATTERN = re.compile(
    r"^(Running|Executing|\[INFO\]|Step \d+/\d+|\d+%)", re.MULTILINE
)
ERROR_PATTERNS = [
    re.compile(r"Traceback \(most recent call last\)", re.MULTILINE),
    re.compile(r"Exception in thread", re.MULTILINE),
    re.compile(r"at .*:\d+", re.MULTILINE),
    re.compile(r"Error:.*at line \d+", re.MULTILINE),
    re.compile(r"^\s+File \".*\", line \d+", re.MULTILINE),
]


class KnowledgeExtractor:
    """Extract knowledge candidates from JSONL conversation logs."""

    def __init__(self, projects_dir: str = "~/.claude/projects"):
        self.projects_dir = Path(projects_dir).expanduser()

    def find_jsonl_files(self, target_date: str) -> list[Path]:
        """
        Find JSONL files matching the target date.

        Args:
            target_date: Date in YYYY-MM-DD format

        Returns:
            list[Path]: List of matching JSONL files
        """
        jsonl_files = []
        if not self.projects_dir.exists():
            return jsonl_files

        # Search for JSONL files in project directories
        for jsonl_file in self.projects_dir.rglob("*.jsonl"):
            jsonl_files.append(jsonl_file)

        return jsonl_files

    def extract_from_file(self, jsonl_file: Path, target_date: str) -> list[dict[str, Any]]:
        """
        Extract knowledge candidates from a single JSONL file.

        Args:
            jsonl_file: Path to JSONL file
            target_date: Date in YYYY-MM-DD format

        Returns:
            list[dict]: List of knowledge candidates
        """
        candidates = []
        target_dt = datetime.strptime(target_date, "%Y-%m-%d")
        next_day = target_dt + timedelta(days=1)

        # Get file-level project_path for fallback
        file_project_path = self._get_file_project_path(jsonl_file)

        try:
            with open(jsonl_file) as f:
                for line_num, line in enumerate(f, 1):
                    try:
                        entry = json.loads(line)

                        # Check if entry is within target date
                        timestamp = entry.get("timestamp")
                        if not timestamp:
                            continue

                        entry_dt = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
                        if not (target_dt <= entry_dt.replace(tzinfo=None) < next_day):
                            continue

                        # Extract relevant content
                        candidate = self._extract_candidate(
                            entry, jsonl_file, line_num, file_project_path
                        )
                        if candidate:
                            candidates.append(candidate)

                    except json.JSONDecodeError:
                        continue
                    except Exception as e:
                        print(f"Warning: Error processing line {line_num} in {jsonl_file}: {e}")
                        continue

        except FileNotFoundError:
            print(f"Warning: File not found: {jsonl_file}")
        except Exception as e:
            print(f"Warning: Error reading {jsonl_file}: {e}")

        return candidates

    def _should_exclude(self, text: str, role: str) -> tuple[bool, str | None]:
        """
        Pre-filter to exclude clearly low-value candidates.

        Args:
            text: Message text
            role: Message role

        Returns:
            tuple[bool, str | None]: (should_exclude, reason)
        """
        # Minimum character count
        if len(text) < 80:
            return True, "Too short"

        # System role
        if role == "system":
            return True, "System role"

        # Exclusion patterns (using pre-compiled regex for performance)
        exclusion_checks = [
            (SYSTEM_MESSAGE_PATTERN, "System message"),
            (COMPLETION_PATTERN, "Completion phrase"),
            (GREETING_PATTERN, "Greeting"),
            (EXECUTION_LOG_PATTERN, "Execution log"),
        ]

        for pattern, reason in exclusion_checks:
            if pattern.search(text):
                return True, reason

        return False, None

    def _get_file_project_path(self, jsonl_file: Path) -> str:
        """
        Get the project path from the first entry with cwd field.

        Args:
            jsonl_file: Path to JSONL file

        Returns:
            str: Project path or empty string if not found
        """
        try:
            with open(jsonl_file) as f:
                for line in f:
                    try:
                        entry = json.loads(line)
                        cwd = entry.get("cwd")
                        if cwd:
                            return cwd
                    except json.JSONDecodeError:
                        continue
        except Exception:
            pass
        return ""

    def _extract_candidate(
        self, entry: dict[str, Any], source_file: Path, line_num: int,
        fallback_project_path: str = ""
    ) -> dict[str, Any] | None:
        """
        Extract a knowledge candidate from a JSONL entry.

        Args:
            entry: JSONL entry as dict
            source_file: Source file path
            line_num: Line number in source file

        Returns:
            dict | None: Knowledge candidate or None if not relevant
        """
        # Claude Code JSONL structure: message is nested inside entry
        message = entry.get("message")
        if not message:
            return None

        role = message.get("role")
        content = message.get("content")

        if not role or not content:
            return None

        # Extract text content
        text_content = ""
        tool_uses = []
        errors = []

        if isinstance(content, str):
            text_content = content
        elif isinstance(content, list):
            for item in content:
                if isinstance(item, dict):
                    if item.get("type") == "text":
                        text_content += item.get("text", "") + "\n"
                    elif item.get("type") == "tool_use":
                        tool_uses.append(
                            {
                                "name": item.get("name"),
                                "input": item.get("input"),
                            }
                        )
                elif isinstance(item, str):
                    text_content += item + "\n"

        # Look for actual error patterns (stack traces, exceptions)
        # Only include if it looks like a real error with context
        for pattern in ERROR_PATTERNS:
            if pattern.search(text_content):
                errors.append(text_content)
                break

        # Skip if no meaningful content
        text_content = text_content.strip()
        should_exclude, _ = self._should_exclude(text_content, role)
        if should_exclude:
            return None
        if not text_content and not tool_uses and not errors:
            return None

        return {
            "timestamp": entry.get("timestamp"),
            "role": role,
            "text": text_content,
            "tool_uses": tool_uses,
            "errors": errors,
            "source_file": str(source_file),
            "line_number": line_num,
            "project_path": entry.get("cwd") or fallback_project_path,
        }

    def extract_for_date(self, target_date: str) -> list[dict[str, Any]]:
        """
        Extract all knowledge candidates for a specific date.

        Args:
            target_date: Date in YYYY-MM-DD format

        Returns:
            list[dict]: All knowledge candidates for the date
        """
        all_candidates = []

        jsonl_files = self.find_jsonl_files(target_date)
        print(f"Found {len(jsonl_files)} JSONL files")

        for jsonl_file in jsonl_files:
            candidates = self.extract_from_file(jsonl_file, target_date)
            if candidates:
                print(f"  {jsonl_file.name}: {len(candidates)} candidates")
                all_candidates.extend(candidates)

        return all_candidates


def main():
    """CLI interface."""
    import sys

    if len(sys.argv) < 2:
        # Default to yesterday
        yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
        target_date = yesterday
    else:
        target_date = sys.argv[1]

    print(f"Extracting knowledge for: {target_date}")

    extractor = KnowledgeExtractor()
    candidates = extractor.extract_for_date(target_date)

    print(f"\n✅ Total candidates extracted: {len(candidates)}")

    # Output as JSON
    output_file = Path(f"/tmp/knowledge_candidates_{target_date}.json")
    with open(output_file, "w") as f:
        json.dump(candidates, f, indent=2, ensure_ascii=False)

    print(f"📝 Saved to: {output_file}")


if __name__ == "__main__":
    main()
