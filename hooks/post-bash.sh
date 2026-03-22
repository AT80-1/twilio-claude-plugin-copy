#!/bin/bash
# ABOUTME: Post-bash hook for tracking command completions.
# ABOUTME: Logs deployment completions and sends notifications for key operations.

# ============================================
# PARSE TOOL INPUT FROM STDIN
# ============================================
# Claude Code passes tool input as JSON on stdin, not env vars.
# Capture it before anything else consumes stdin.
_POST_BASH_HOOK_INPUT=""
if [ ! -t 0 ]; then
    _POST_BASH_HOOK_INPUT="$(cat)"
fi

COMMAND=""
_POST_BASH_SESSION_ID=""
if [ -n "$_POST_BASH_HOOK_INPUT" ] && ! command -v jq &> /dev/null; then
    echo "WARNING: jq not installed — post-bash hooks disabled (deployment tracking). Run: brew install jq" >&2
fi
if [ -n "$_POST_BASH_HOOK_INPUT" ] && command -v jq &> /dev/null; then
    COMMAND="$(echo "$_POST_BASH_HOOK_INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
    _POST_BASH_SESSION_ID="$(echo "$_POST_BASH_HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null)"
fi

# Exit if no command
if [ -z "$COMMAND" ]; then
    exit 0
fi

# ============================================
# DEPLOYMENT COMPLETION
# ============================================

if echo "$COMMAND" | grep -qE "(twilio\s+serverless:deploy|npm\s+run\s+deploy)"; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Deployment command completed."
    echo "Check the output above for deployed URLs."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Send desktop notification on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e 'display notification "Deployment complete - check terminal for URLs" with title "Claude Code" sound name "Hero"' 2>/dev/null || true
    elif command -v notify-send &> /dev/null; then
        notify-send "Claude Code" "Deployment complete" 2>/dev/null || true
    fi
fi

# ============================================
# TEST COMPLETION
# ============================================

if echo "$COMMAND" | grep -qE "(npm\s+test|npm\s+run\s+test)"; then
    echo ""
    echo "Test execution completed."
fi

# ============================================
# STRUCTURED EVENT EMISSION (observability)
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/_emit-event.sh" ]; then
    source "$SCRIPT_DIR/_emit-event.sh"
    EMIT_SESSION_ID="$_POST_BASH_SESSION_ID"

    # Emit bash_command event for every command
    emit_event "bash_command" "$(jq -nc --arg cmd "$COMMAND" '{command: $cmd}')"

    # Emit specialized test_run event when tests are run
    if echo "$COMMAND" | grep -qE "(npm\s+(test|run\s+test)|jest|vitest)"; then
        emit_event "test_run" "$(jq -nc --arg cmd "$COMMAND" '{command: $cmd}')"
    fi

    # Emit deploy event when deployment commands are run
    if echo "$COMMAND" | grep -qE "(twilio\s+serverless:deploy|npm\s+run\s+deploy)"; then
        emit_event "deploy" "$(jq -nc --arg cmd "$COMMAND" '{command: $cmd}')"
    fi
fi

exit 0
