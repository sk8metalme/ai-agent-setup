#!/usr/bin/env python3
"""
Daily trigger management for knowledge sync.
Ensures the skill runs only once per day.
"""

import os
from datetime import datetime
from pathlib import Path


class DailyTriggerManager:
    """Manages daily trigger state to ensure once-per-day execution."""

    def __init__(self, state_dir: str = "~/.claude/daily_knowledge"):
        self.state_dir = Path(state_dir).expanduser()
        self.state_file = self.state_dir / "last_run.txt"
        self._ensure_state_dir()

    def _ensure_state_dir(self):
        """Create state directory if it doesn't exist."""
        self.state_dir.mkdir(parents=True, exist_ok=True)

    def should_run_today(self) -> bool:
        """
        Check if the skill should run today.

        Returns:
            bool: True if should run, False if already ran today
        """
        today = datetime.now().strftime("%Y-%m-%d")

        if not self.state_file.exists():
            return True

        last_run = self.state_file.read_text().strip()
        return last_run != today

    def mark_as_run(self):
        """Mark today as having been processed."""
        today = datetime.now().strftime("%Y-%m-%d")
        self.state_file.write_text(today)

    def get_last_run_date(self) -> str | None:
        """
        Get the last run date.

        Returns:
            str | None: Last run date in YYYY-MM-DD format, or None if never run
        """
        if not self.state_file.exists():
            return None
        return self.state_file.read_text().strip()


def main():
    """CLI interface for testing."""
    import sys

    manager = DailyTriggerManager()

    if len(sys.argv) > 1 and sys.argv[1] == "check":
        if manager.should_run_today():
            print("✅ Should run today")
            sys.exit(0)
        else:
            print("⏭️  Already ran today")
            sys.exit(1)

    elif len(sys.argv) > 1 and sys.argv[1] == "mark":
        manager.mark_as_run()
        print(f"✅ Marked as run: {datetime.now().strftime('%Y-%m-%d')}")
        sys.exit(0)

    elif len(sys.argv) > 1 and sys.argv[1] == "status":
        last_run = manager.get_last_run_date()
        if last_run:
            print(f"Last run: {last_run}")
        else:
            print("Never run")

        if manager.should_run_today():
            print("Status: Ready to run")
        else:
            print("Status: Already ran today")
        sys.exit(0)

    else:
        print("Usage:")
        print("  python manage_daily_trigger.py check   # Exit 0 if should run, 1 if not")
        print("  python manage_daily_trigger.py mark    # Mark today as processed")
        print("  python manage_daily_trigger.py status  # Show current status")
        sys.exit(1)


if __name__ == "__main__":
    main()
