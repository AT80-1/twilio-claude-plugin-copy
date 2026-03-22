---
name: hooks-reference
description: Reference for project hook configuration. Use when understanding pre/post tool hooks, modifying quality gates, or debugging why a hook blocked an action.
---

# Claude Code Hooks Reference

This project uses Claude Code hooks (configured in `.claude/settings.json`) to enforce coding standards automatically.

## Active Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `pre-write-validate.sh` | PreToolUse (Write/Edit) | Blocks credentials, magic test numbers; warns on naming |
| `pre-bash-validate.sh` | PreToolUse (Bash) | Blocks --no-verify, pending-actions, validates deploy |
| `post-write.sh` | PostToolUse (Write/Edit) | Auto-lints JS/TS files, tracks files to .session-files |
| `post-bash.sh` | PostToolUse (Bash) | Logs deploy/test completions |
| `subagent-log.sh` | SubagentStop | Logs workflow activity |
| `session-checklist.sh` | Stop | Warns about uncommitted changes, unpushed commits, stale learnings |
| `notify-ready.sh` | Stop | Desktop notification when done |
| `session-start.sh` | SessionStart (all) | Logs session starts, bootstrap checks, context loading |

## When a Hook Blocks You

**Fix the hook, don't bypass the system.** If a hook is blocking legitimate work:
- Open a separate Claude window and fix the hook behavior
- Use `CLAUDE_ALLOW_PRODUCTION_WRITE=true` for one-off overrides

## What Gets Blocked (Exit Code 2)

- Hardcoded Twilio credentials (`AC...`, `SK...`, auth tokens)
- `git commit --no-verify` or `git commit -n`
- `git commit` with unaddressed pending-actions.json (override: `SKIP_PENDING_ACTIONS=true`)
- `git commit` with TypeScript compilation errors in staged `.ts/.tsx` files (override: `SKIP_TSC_CHECK=true`)
- `git push --force` to main/master
- Deployment when tests fail
- Deployment when coverage < 80% (statements or branches)
- Deployment when linting fails
- New function files without ABOUTME comments
- Twilio magic test numbers (`+15005550xxx`) in non-test files

## What Gets Warned (Non-blocking)

- Non-evergreen naming patterns (`ImprovedX`, `NewHandler`, `BetterY`, `EnhancedZ`)
- High-risk assertions in CLAUDE.md files without citations
- Test files without ABOUTME comments

## Commit Checklist

On every `git commit`, the hook displays a reminder checklist:
- Updated todo.md?
- Captured learnings?
- Design decision documented if architectural?

## Hook Scripts Location

All hook scripts are in `.claude/hooks/` and can be modified to adjust behavior.

## Plan Archival

When a Claude Code session ends, `archive-plan.sh` preserves the current plan file.

**What gets archived:**
- Plans modified within the last hour (likely from current session)
- Plan content with added metadata header (timestamp, branch, project, source)
- Descriptive filename: `YYYY-MM-DD-HHMMSS-plan-title-slug.md`

**Metadata captured:**
```yaml
archived: 2026-02-01T15:30:45-08:00
branch: main
project: twilio-feature-factory
source: ~/.claude/plans/deep-nibbling-castle.md
title: Plan Title From First Heading
```
