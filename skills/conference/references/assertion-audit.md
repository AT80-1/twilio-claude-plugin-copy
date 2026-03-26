---
name: assertion-audit
description: Adversarial assertion audit for conference skill with 155 claims verified.
---

<!-- ABOUTME: Adversarial assertion audit for conference skill with CONFIRMED/CORRECTED/QUALIFIED verdicts. -->
<!-- ABOUTME: 155 factual claims extracted, classified, and pressure-tested with SID evidence. -->

# Conference Skill — Assertion Audit

**Skill**: conference
**Audit date**: 2026-03-24
**Auditor**: Claude + MC

## Summary

| Verdict | Count |
|---------|-------|
| CONFIRMED | 42 |
| CORRECTED | 1 |
| QUALIFIED | 6 |
| DOC-SOURCED | 106 |
| **Total** | **155** |

**DOC-SOURCED** means: sourced from authoritative Twilio documentation, not independently verified by our live tests. These are not speculative — they come from the API reference, TwiML docs, or Console docs.

## CORRECTED Assertions (1)

### #36: startConferenceOnEnter=false behavior

**Original claim**: "If all participants have startConferenceOnEnter=false, the conference stays in `init` permanently."

**Actual behavior**: Conference status showed `in-progress` with participants `muted: false` and `status: connected`. The REST API does not reflect the expected `init` state or auto-mute.

**Correction applied**: Gotcha #2 in SKILL.md updated to note that REST API may show `in-progress` with `muted: false` even when all participants have startConferenceOnEnter=false.

## QUALIFIED Assertions (6)

### #43/#67: TwiML update + endConferenceOnExit=true teardown
**Caveat**: Confirmed TwiML update exits conference, but tested with endConferenceOnExit=false. The combination with true was not independently tested.

### #62: Moderated conference init state
**Caveat**: Conference showed `in-progress` even with all participants having startConferenceOnEnter=false. Audio-level behavior may still match docs.

### #94: Coaching Insights events
**Caveat**: Hold/unhold/mute events confirmed but coaching-specific event names not explicitly verified.

### #124/#125: Insights timing
**Caveat**: Based on single test session. Timing may vary by load, region, or account.

### #155: processing_state naming inconsistency
**Caveat**: Conference Summary API had "partial" instead of "in_progress". Typo corrected.

## High-Priority DOC-SOURCED Items for Future Testing

| # | Assertion | Risk | Why |
|---|-----------|------|-----|
| 5 | Only one in-progress conference per friendlyName | HIGH | Name collision could silently merge callers |
| 25 | Reusing active friendlyName merges callers | HIGH | Related to #5, could cause data leakage |
| 44 | Participants API to Twilio number invokes voice URL | HIGH | Common gotcha |
| 48/106 | 1 CPS rate limit for Participants API | MEDIUM | Could hit in production |
| 50 | waitUrl failure breaks conference silently | HIGH | Silent failure mode |
| 99 | waitUrl does NOT auto-loop | MEDIUM | Hold music cuts out |
| 101 | AnnounceUrl plays to specific participant only | MEDIUM | Audio routing claim |
