#!/bin/bash
# Integrated statusLine script for Claude Code
# Displays: CWD | ccstatusline output

# Read JSON input from stdin
input=$(cat)

# Extract cwd from JSON and format it (last 2 path segments)
cwd=$(echo "$input" | jq -r '.cwd | split("/") | .[-2:] | join("/")')

# Get ccstatusline output by passing the same JSON input
# Capture both stdout and stderr
stderr_file=$(mktemp)
ccstatusline_output=$(echo "$input" | ccstatusline 2>"$stderr_file")
ccstatusline_exit=$?

# Check if ccstatusline failed
if [ $ccstatusline_exit -ne 0 ] || [ -z "$ccstatusline_output" ]; then
  # Log error if stderr is not empty
  if [ -s "$stderr_file" ]; then
    log_dir="$HOME/.claude/logs"
    mkdir -p "$log_dir"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ccstatusline error (exit: $ccstatusline_exit):" >> "$log_dir/statusline.log"
    cat "$stderr_file" >> "$log_dir/statusline.log"
    echo "" >> "$log_dir/statusline.log"
  fi

  # Fallback: display basic info without ccstatusline
  model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
  branch=$(git branch --show-current 2>/dev/null || echo "-")

  if [ -n "$cwd" ] && [ "$cwd" != "null" ]; then
    echo "$cwd | Model: $model | ⎇ $branch [ccstatusline unavailable]"
  else
    echo "Model: $model | ⎇ $branch [ccstatusline unavailable]"
  fi
else
  # Normal operation: combine cwd and ccstatusline output
  if [ -n "$cwd" ] && [ "$cwd" != "null" ]; then
    echo "$cwd | $ccstatusline_output"
  else
    echo "$ccstatusline_output"
  fi
fi

# Cleanup
rm -f "$stderr_file"
