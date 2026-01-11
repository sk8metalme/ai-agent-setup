#!/bin/bash
# Integrated statusLine script for Claude Code
# Displays: CWD | ccstatusline output

# Read JSON input from stdin
input=$(cat)

# Extract cwd from JSON and format it (last 2 path segments)
cwd=$(echo "$input" | jq -r '.cwd | split("/") | .[-2:] | join("/")')

# Get ccstatusline output by passing the same JSON input
ccstatusline_output=$(echo "$input" | ccstatusline 2>/dev/null)

# Combine outputs
if [ -n "$cwd" ] && [ "$cwd" != "null" ]; then
  echo "$cwd | $ccstatusline_output"
else
  echo "$ccstatusline_output"
fi
