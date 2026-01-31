#!/usr/bin/env python3
"""
Knowledge evaluation engine with scoring system.

Evaluates knowledge candidates based on:
- Exclusion patterns
- Content quality scoring
- Tool usage analysis
- Role-based weighting
"""

import re
import yaml
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class EvaluationResult:
    """Result of knowledge evaluation."""

    score: int
    category: str  # accept, maybe, reject
    reasons: list[str] = field(default_factory=list)
    excluded_by: str | None = None


class KnowledgeEvaluator:
    """Evaluate knowledge candidates using scoring system."""

    def __init__(self, config_dir: str | None = None):
        """
        Initialize evaluator.

        Args:
            config_dir: Path to config directory (default: adjacent to this file)
        """
        if config_dir is None:
            script_dir = Path(__file__).parent
            config_dir = script_dir.parent / "config"

        self.config_dir = Path(config_dir)
        self._load_configs()

    def _load_configs(self):
        """Load all configuration files."""
        # Load exclusion patterns
        with open(self.config_dir / "exclusion_patterns.yaml") as f:
            self.exclusion_config = yaml.safe_load(f)

        # Load scoring rules
        with open(self.config_dir / "scoring_rules.yaml") as f:
            self.scoring_config = yaml.safe_load(f)

        # Load tool classifications
        with open(self.config_dir / "tool_classifications.yaml") as f:
            self.tool_config = yaml.safe_load(f)

    def evaluate(self, candidate: dict[str, Any]) -> EvaluationResult:
        """
        Evaluate a knowledge candidate.

        Args:
            candidate: Knowledge candidate dict with keys:
                - text: Main text content
                - role: Message role (assistant/user/system)
                - tool_uses: List of tool usage dicts
                - errors: List of error strings

        Returns:
            EvaluationResult with score and category
        """
        text = candidate.get("text", "")
        role = candidate.get("role", "")
        tool_uses = candidate.get("tool_uses", [])

        # Check exclusion patterns first
        excluded_by = self._check_exclusions(text, role)
        if excluded_by:
            return EvaluationResult(
                score=0,
                category="reject",
                excluded_by=excluded_by,
                reasons=[f"Excluded by: {excluded_by}"],
            )

        # Calculate score
        score = 0
        reasons = []

        # 1. Positive scores
        positive_score, positive_reasons = self._calculate_positive_scores(
            text, tool_uses
        )
        score += positive_score
        reasons.extend(positive_reasons)

        # 2. Negative scores
        negative_score, negative_reasons = self._calculate_negative_scores(text)
        score += negative_score
        reasons.extend(negative_reasons)

        # 3. Tool usage scores
        tool_score, tool_reasons = self._calculate_tool_scores(tool_uses)
        score += tool_score
        reasons.extend(tool_reasons)

        # 4. Length bonus/penalty
        length_score, length_reason = self._calculate_length_score(text)
        score += length_score
        if length_reason:
            reasons.append(length_reason)

        # 5. Apply role weight
        role_weight = self.scoring_config["role_weights"].get(role, 1.0)
        score = int(score * role_weight)
        if role_weight != 1.0:
            reasons.append(f"Role weight ({role}): {role_weight}x")

        # Determine category
        thresholds = self.scoring_config["thresholds"]
        if score >= thresholds["accept"]:
            category = "accept"
        elif score >= thresholds["maybe"]:
            category = "maybe"
        else:
            category = "reject"

        return EvaluationResult(score=score, category=category, reasons=reasons)

    def _check_exclusions(self, text: str, role: str) -> str | None:
        """
        Check if text matches exclusion patterns.

        Returns:
            str | None: Exclusion reason if matched, None otherwise
        """
        # Check minimum length
        min_length = self.exclusion_config["min_text_length"]
        if len(text) < min_length:
            return f"Text too short (< {min_length} chars)"

        # Check excluded roles
        if role in self.exclusion_config["excluded_roles"]:
            return f"Excluded role: {role}"

        # Check exclusion patterns
        patterns = self.exclusion_config["exclusion_patterns"]
        for category, pattern_list in patterns.items():
            for pattern in pattern_list:
                if re.search(pattern, text, re.IGNORECASE):
                    return f"Matched exclusion: {category}"

        return None

    def _calculate_positive_scores(
        self, text: str, tool_uses: list[dict]
    ) -> tuple[int, list[str]]:
        """Calculate positive scores from text content."""
        score = 0
        reasons = []

        positive_rules = self.scoring_config["positive_scores"]

        # Check each positive pattern
        for rule_name, rule_config in positive_rules.items():
            if "patterns" in rule_config:
                for pattern in rule_config["patterns"]:
                    if re.search(pattern, text, re.IGNORECASE):
                        score += rule_config["score"]
                        reasons.append(f"+{rule_config['score']} ({rule_name})")
                        break  # Only count once per rule

            elif "tools" in rule_config:
                # Check tool usage
                tool_names = {t.get("name") for t in tool_uses if t.get("name")}
                for tool in rule_config["tools"]:
                    if tool in tool_names:
                        score += rule_config["score"]
                        reasons.append(f"+{rule_config['score']} ({rule_name}: {tool})")
                        break

        return score, reasons

    def _calculate_negative_scores(self, text: str) -> tuple[int, list[str]]:
        """Calculate negative scores from text content."""
        score = 0
        reasons = []

        negative_rules = self.scoring_config["negative_scores"]

        for rule_name, rule_config in negative_rules.items():
            for pattern in rule_config["patterns"]:
                if re.search(pattern, text, re.IGNORECASE | re.MULTILINE):
                    score += rule_config["score"]  # Already negative
                    reasons.append(f"{rule_config['score']} ({rule_name})")
                    break

        return score, reasons

    def _calculate_tool_scores(
        self, tool_uses: list[dict]
    ) -> tuple[int, list[str]]:
        """Calculate scores based on tool usage."""
        if not tool_uses:
            return 0, []

        score = 0
        reasons = []
        tool_names = [t.get("name") for t in tool_uses if t.get("name")]

        # Individual tool scores
        tool_scores = self.tool_config["tool_scores"]
        for tool_name in tool_names:
            tool_score = tool_scores.get(tool_name, 0)
            if tool_score != 0:
                score += tool_score
                reasons.append(f"+{tool_score} (tool: {tool_name})")

        # Check tool combinations
        combinations = self.tool_config["tool_combinations"]
        for combo_name, combo_config in combinations.items():
            if "tools" in combo_config:
                # Specific tool combination
                required_tools = set(combo_config["tools"])
                if required_tools.issubset(set(tool_names)):
                    bonus = combo_config["bonus"]
                    score += bonus
                    reasons.append(f"+{bonus} (combo: {combo_name})")

            elif "min_tools" in combo_config:
                # Minimum number of tools
                if len(set(tool_names)) >= combo_config["min_tools"]:
                    bonus = combo_config["bonus"]
                    score += bonus
                    reasons.append(f"+{bonus} (combo: {combo_name})")

        return score, reasons

    def _calculate_length_score(self, text: str) -> tuple[int, str | None]:
        """Calculate score based on text length."""
        length = len(text)
        length_config = self.scoring_config["length_bonus"]

        # Check if optimal length
        if length_config["optimal_min"] <= length <= length_config["optimal_max"]:
            return length_config["bonus"], f"+{length_config['bonus']} (optimal length)"

        # Too short
        if length < length_config["too_short"]:
            return (
                length_config["penalty"],
                f"{length_config['penalty']} (too short: {length} chars)",
            )

        # Too long
        if length > length_config["too_long"]:
            return (
                length_config["penalty"],
                f"{length_config['penalty']} (too long: {length} chars)",
            )

        return 0, None


def main():
    """CLI interface for testing."""
    import json
    import sys

    if len(sys.argv) < 2:
        print("Usage:")
        print("  python evaluate_knowledge.py <candidates_json_file>")
        print()
        print("Output:")
        print("  - Evaluation results for each candidate")
        print("  - Statistics (accept/maybe/reject counts)")
        sys.exit(1)

    candidates_file = Path(sys.argv[1])
    if not candidates_file.exists():
        print(f"Error: File not found: {candidates_file}")
        sys.exit(1)

    # Load candidates
    with open(candidates_file) as f:
        candidates = json.load(f)

    print(f"Evaluating {len(candidates)} candidates...")
    print()

    # Evaluate
    evaluator = KnowledgeEvaluator()
    results = []

    for i, candidate in enumerate(candidates, 1):
        result = evaluator.evaluate(candidate)
        results.append(result)

        # Print result
        print(f"[{i}/{len(candidates)}] Score: {result.score} | {result.category.upper()}")
        if result.excluded_by:
            print(f"  Excluded: {result.excluded_by}")
        else:
            for reason in result.reasons[:5]:  # Show top 5 reasons
                print(f"  - {reason}")
        print()

    # Print statistics
    accept_count = sum(1 for r in results if r.category == "accept")
    maybe_count = sum(1 for r in results if r.category == "maybe")
    reject_count = sum(1 for r in results if r.category == "reject")

    print("=" * 50)
    print("STATISTICS")
    print("=" * 50)
    print(f"Total candidates: {len(results)}")
    print(f"  ✅ Accept:  {accept_count} ({accept_count/len(results)*100:.1f}%)")
    print(f"  ⚠️  Maybe:   {maybe_count} ({maybe_count/len(results)*100:.1f}%)")
    print(f"  ❌ Reject:  {reject_count} ({reject_count/len(results)*100:.1f}%)")
    print()

    # Score distribution
    scores = [r.score for r in results]
    if scores:
        print(f"Score range: {min(scores)} - {max(scores)}")
        print(f"Average score: {sum(scores)/len(scores):.1f}")


if __name__ == "__main__":
    main()
