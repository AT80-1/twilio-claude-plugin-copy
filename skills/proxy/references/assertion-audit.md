---
name: assertion-audit
description: Adversarial assertion audit for the Proxy skill with 48 verified claims.
---

<!-- ABOUTME: Adversarial assertion audit for the Proxy skill. Every factual claim pressure-tested with evidence. -->
<!-- ABOUTME: Proves provenance chain for all behavioral claims. 48 assertions extracted, audited 2026-03-25. -->

# Assertion Audit Log

**Skill**: proxy
**Audit date**: 2026-03-25
**Auditor**: Claude + MC

## Summary

| Verdict | Count |
|---------|-------|
| CONFIRMED | 39 |
| CORRECTED | 2 |
| QUALIFIED | 7 |
| REMOVED | 0 |
| **Total** | **48** |

## Corrections Applied

### C1: Error 80608 message clarification
- **Original text**: "Session status change not supported"
- **Corrected text**: Added the full error message guidance: "To re-open a session, choose In Progress."

### C2: Error 80609 exact wording
- **Original text**: Described as "max 2 participants"
- **Corrected text**: Exact message: "A Session may have at most 2 participants"

## Qualifications Applied

- **Q1**: TTL reset on interaction — Not live-tested; would require actual voice call or SMS through proxy.
- **Q2**: Intercept callback 403 blocking — Not live-tested; would require deployed intercept webhook.
- **Q3**: Out-of-session auto-create — Not live-tested. Docs confirm JSON response format.
- **Q4**: Interaction resource fields — No interactions generated during testing.
- **Q5**: Cross-service number restriction — Tested duplicate within same service; cross-service from docs.
- **Q6**: Pool size limits — 5000/500 limits from docs, not live-tested.
- **Q7**: Stickiness behavioral difference — Set and confirmed; behavioral difference needs multi-session test.
