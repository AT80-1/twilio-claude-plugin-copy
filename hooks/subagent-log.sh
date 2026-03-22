#!/bin/bash
# ABOUTME: Hook for SubagentStop events - logs agent type and activity.
# ABOUTME: Runs after any subagent completes work with timestamped logging.

# Determine the project root (where plugin is installed or logs should go)
PROJECT_ROOT="${PWD}"
LOG_DIR="$PROJECT_ROOT/.claude/logs"
LOG_FILE="$LOG_DIR/subagent-activity.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Read JSON input from stdin
HOOK_INPUT=""
if [ ! -t 0 ]; then
    HOOK_INPUT="$(cat)"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Log agent completion with type info if available
if [ -n "$HOOK_INPUT" ] && command -v jq &>/dev/null; then
    AGENT_TYPE=$(echo "$HOOK_INPUT" | jq -r '.agent_type // "unknown"' 2>/dev/null)
    AGENT_ID=$(echo "$HOOK_INPUT" | jq -r '.agent_id // ""' 2>/dev/null)
    if [ "$AGENT_TYPE" != "unknown" ] && [ "$AGENT_TYPE" != "null" ]; then
        echo "Subagent completed: type=$AGENT_TYPE id=${AGENT_ID:0:8}" >&2
    fi
fi

# Structured event emission (observability)
if [ -n "$HOOK_INPUT" ] && command -v jq &>/dev/null; then
    SUBAGENT_SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""' 2>/dev/null)
    if [ -f "$SCRIPT_DIR/_emit-event.sh" ]; then
        source "$SCRIPT_DIR/_emit-event.sh"
        EMIT_SESSION_ID="$SUBAGENT_SESSION_ID"
        emit_event "subagent_complete" "$(jq -nc \
            --arg type "${AGENT_TYPE:-unknown}" \
            --arg aid "${AGENT_ID:-}" \
            '{subagent_type: $type, agent_id: $aid}')"
    fi
fi

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Get git context if available
GIT_BRANCH="N/A"
if [ -d "$PROJECT_ROOT/.git" ]; then
    GIT_BRANCH=$(cd "$PROJECT_ROOT" && git branch --show-current 2>/dev/null || echo "N/A")
fi

# Log the subagent completion
{
    echo "[$TIMESTAMP] Subagent completed"
    echo "  Branch: $GIT_BRANCH"
    echo "  Directory: $(pwd)"
    echo "---"
} >> "$LOG_FILE"

# Keep log file from growing too large (keep last 500 lines)
if [ -f "$LOG_FILE" ]; then
    LINES=$(wc -l < "$LOG_FILE" | tr -d ' ')
    if [ "$LINES" -gt 500 ]; then
        tail -500 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi
fi

exit 0
