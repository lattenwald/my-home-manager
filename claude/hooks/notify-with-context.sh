#!/bin/bash

# Read JSON input from stdin
INPUT=$(cat)

# Extract current working directory from JSON
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Get project name from directory
if [ -n "$CWD" ]; then
    PROJECT=$(basename "$CWD")
else
    PROJECT=$(basename "$CLAUDE_PROJECT_DIR")
fi

# Send desktop notification with project context
notify-send "Claude Code: $PROJECT" "Awaiting your input"
