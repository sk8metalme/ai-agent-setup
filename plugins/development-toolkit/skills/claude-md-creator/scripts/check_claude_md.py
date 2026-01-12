#!/usr/bin/env python3
"""
CLAUDE.md Quality Checker

Validates CLAUDE.md structure, content, and best practices compliance.
Provides detailed improvement suggestions.

Usage:
    python check_claude_md.py /path/to/CLAUDE.md
"""

import sys
import re
from collections import defaultdict
from pathlib import Path
from typing import List, Dict
from dataclasses import dataclass, field
from enum import Enum


class Severity(Enum):
    """Issue severity levels"""
    ERROR = "ERROR"
    WARNING = "WARNING"
    INFO = "INFO"


@dataclass
class Issue:
    """Represents a validation issue"""
    severity: Severity
    category: str
    message: str
    line_number: int = 0
    suggestion: str = ""


@dataclass
class ValidationResult:
    """Validation result with issues and score"""
    issues: List[Issue] = field(default_factory=list)
    score: int = 100

    def add_issue(self, issue: Issue):
        """Add an issue and adjust score"""
        self.issues.append(issue)
        if issue.severity == Severity.ERROR:
            self.score -= 10
        elif issue.severity == Severity.WARNING:
            self.score -= 5
        elif issue.severity == Severity.INFO:
            self.score -= 2
        self.score = max(0, self.score)

    def count_by_severity(self) -> Dict[Severity, int]:
        """Count issues by severity level"""
        counts = {severity: 0 for severity in Severity}
        for issue in self.issues:
            counts[issue.severity] += 1
        return counts


class ClaudeMdChecker:
    """CLAUDE.md validator"""

    RECOMMENDED_SECTIONS = [
        "overview",
        "architecture",
        "setup",
        "development",
        "testing",
        "deployment",
        "contributing",
    ]

    TOOL_KEYWORDS = frozenset([
        'npm', 'pip', 'cargo', 'maven', 'gradle', 'make',
        'python', 'node', 'java', 'rust', 'go'
    ])

    PATH_INDICATORS = frozenset(['/', '.', '_'])

    def __init__(self, file_path: Path):
        self.file_path = file_path
        self.content = ""
        self.lines = []

    def load(self) -> bool:
        """Load CLAUDE.md file"""
        try:
            self.content = self.file_path.read_text(encoding='utf-8')
            self.lines = self.content.split('\n')
            return True
        except Exception as e:
            print(f"Error loading file: {e}")
            return False

    def validate(self) -> ValidationResult:
        """Run all validations"""
        result = ValidationResult()

        # Basic checks
        self._check_file_size(result)
        self._check_markdown_structure(result)
        self._check_headings(result)
        self._check_code_blocks(result)
        self._check_sections(result)
        self._check_content_quality(result)
        self._check_best_practices(result)

        return result

    def _check_file_size(self, result: ValidationResult):
        """Check if file is too short or too long"""
        line_count = len(self.lines)

        if line_count < 10:
            result.add_issue(Issue(
                severity=Severity.ERROR,
                category="Structure",
                message="CLAUDE.md is too short (less than 10 lines)",
                suggestion="Add more detailed information about your project"
            ))
        elif line_count < 50:
            result.add_issue(Issue(
                severity=Severity.WARNING,
                category="Structure",
                message="CLAUDE.md might be too brief for comprehensive guidance",
                suggestion="Consider adding more details about development workflow, testing, and deployment"
            ))

    def _check_markdown_structure(self, result: ValidationResult):
        """Check basic Markdown syntax"""
        for i, line in enumerate(self.lines, 1):
            # Check for malformed headings
            if line.strip().startswith('#'):
                if not re.match(r'^#{1,6}\s+\S', line):
                    result.add_issue(Issue(
                        severity=Severity.ERROR,
                        category="Markdown Syntax",
                        message=f"Malformed heading at line {i}",
                        line_number=i,
                        suggestion="Headings should have space after # symbols (e.g., '# Heading')"
                    ))

    def _check_headings(self, result: ValidationResult):
        """Check heading hierarchy"""
        headings = []
        for i, line in enumerate(self.lines, 1):
            match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
            if match:
                level = len(match.group(1))
                title = match.group(2).strip()
                headings.append((level, title, i))

        if not headings:
            result.add_issue(Issue(
                severity=Severity.ERROR,
                category="Structure",
                message="No headings found in CLAUDE.md",
                suggestion="Use Markdown headings (# ## ###) to structure your document"
            ))
            return

        # Check if first heading is H1
        if headings[0][0] != 1:
            result.add_issue(Issue(
                severity=Severity.WARNING,
                category="Structure",
                message="First heading should be H1 (# Title)",
                line_number=headings[0][2],
                suggestion="Start your CLAUDE.md with a single # heading"
            ))

        # Check for heading level jumps
        for i in range(1, len(headings)):
            prev_level = headings[i-1][0]
            curr_level = headings[i][0]
            if curr_level > prev_level + 1:
                result.add_issue(Issue(
                    severity=Severity.WARNING,
                    category="Structure",
                    message=f"Heading level jump from H{prev_level} to H{curr_level} at line {headings[i][2]}",
                    line_number=headings[i][2],
                    suggestion="Avoid skipping heading levels (e.g., go from ## to ####)"
                ))

    def _check_code_blocks(self, result: ValidationResult):
        """Check code block formatting"""
        in_code_block = False
        code_block_start = 0

        for i, line in enumerate(self.lines, 1):
            if line.strip().startswith('```'):
                if not in_code_block:
                    in_code_block = True
                    code_block_start = i
                else:
                    in_code_block = False

        if in_code_block:
            result.add_issue(Issue(
                severity=Severity.ERROR,
                category="Markdown Syntax",
                message=f"Unclosed code block starting at line {code_block_start}",
                line_number=code_block_start,
                suggestion="Add closing ``` to close the code block"
            ))

    def _check_sections(self, result: ValidationResult):
        """Check for recommended sections"""
        content_lower = self.content.lower()

        found_sections = []
        missing_sections = []

        for section in self.RECOMMENDED_SECTIONS:
            # Simple heuristic: look for section name in headings
            if re.search(rf'#.*{section}', content_lower):
                found_sections.append(section)
            else:
                missing_sections.append(section)

        if missing_sections:
            result.add_issue(Issue(
                severity=Severity.INFO,
                category="Content",
                message=f"Missing recommended sections: {', '.join(missing_sections)}",
                suggestion="Consider adding these sections for comprehensive project documentation"
            ))

    def _check_content_quality(self, result: ValidationResult):
        """Check content quality indicators"""
        # Check for TODO markers
        todos = [i+1 for i, line in enumerate(self.lines) if 'TODO' in line.upper()]
        if todos:
            result.add_issue(Issue(
                severity=Severity.WARNING,
                category="Content Quality",
                message=f"TODO markers found at lines: {', '.join(map(str, todos[:5]))}{'...' if len(todos) > 5 else ''}",
                suggestion="Complete or remove TODO items before finalizing CLAUDE.md"
            ))

        # Check for very short sections (heading followed immediately by another heading)
        line_count = len(self.lines)
        for i in range(line_count - 1):
            current_line = self.lines[i].strip()
            next_line = self.lines[i + 1].strip()
            if current_line.startswith('#') and next_line.startswith('#'):
                result.add_issue(Issue(
                    severity=Severity.WARNING,
                    category="Content Quality",
                    message=f"Empty section at line {i+1}",
                    line_number=i+1,
                    suggestion="Add content to sections or remove empty headings"
                ))

    def _check_best_practices(self, result: ValidationResult):
        """Check for best practices"""
        content_lower = self.content.lower()

        has_tool_reference = any(kw in content_lower for kw in self.TOOL_KEYWORDS)
        if not has_tool_reference:
            result.add_issue(Issue(
                severity=Severity.INFO,
                category="Best Practices",
                message="No specific tool or language commands found",
                suggestion="Include specific commands (e.g., 'npm install', 'python main.py') for clarity"
            ))

        has_path_reference = any(char in self.content for char in self.PATH_INDICATORS)
        if not has_path_reference:
            result.add_issue(Issue(
                severity=Severity.INFO,
                category="Best Practices",
                message="No file or directory paths found",
                suggestion="Reference specific files/directories (e.g., 'src/', 'config.json') for clarity"
            ))


def print_report(result: ValidationResult, file_path: Path):
    """Print validation report"""
    print("=" * 80)
    print(f"CLAUDE.md Quality Report: {file_path.name}")
    print("=" * 80)
    print()

    print(f"Overall Score: {result.score}/100")
    print()

    if not result.issues:
        print("No issues found! CLAUDE.md looks great.")
        return

    issues_by_category: Dict[str, List[Issue]] = defaultdict(list)
    for issue in result.issues:
        issues_by_category[issue.category].append(issue)

    for category, issues in sorted(issues_by_category.items()):
        print(f"## {category}")
        print()
        for issue in issues:
            print(f"[{issue.severity.value}] {issue.message}")
            if issue.line_number:
                print(f"   Line: {issue.line_number}")
            if issue.suggestion:
                print(f"   Suggestion: {issue.suggestion}")
            print()

    counts = result.count_by_severity()
    print("=" * 80)
    print(f"Total Issues: {len(result.issues)}")
    print(f"  Errors: {counts[Severity.ERROR]}")
    print(f"  Warnings: {counts[Severity.WARNING]}")
    print(f"  Info: {counts[Severity.INFO]}")
    print("=" * 80)


def main():
    if len(sys.argv) < 2:
        print("Usage: python check_claude_md.py <path-to-CLAUDE.md>")
        sys.exit(1)

    file_path = Path(sys.argv[1])

    if not file_path.exists():
        print(f"Error: File not found: {file_path}")
        sys.exit(1)

    if file_path.name.upper() != "CLAUDE.MD":
        print(f"Warning: File name is '{file_path.name}', expected 'CLAUDE.md'")

    checker = ClaudeMdChecker(file_path)

    if not checker.load():
        sys.exit(1)

    result = checker.validate()
    print_report(result, file_path)

    # Exit code based on errors
    counts = result.count_by_severity()
    sys.exit(1 if counts[Severity.ERROR] > 0 else 0)


if __name__ == "__main__":
    main()
