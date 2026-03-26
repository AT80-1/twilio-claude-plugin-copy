---
name: assertion-audit
description: Adversarial assertion audit for the TaskRouter skill with 68 verified claims.
---

<!-- ABOUTME: Adversarial assertion audit for the TaskRouter skill. Every factual claim pressure-tested with evidence. -->
<!-- ABOUTME: Proves provenance chain for all behavioral claims. 68 assertions extracted, audited 2026-03-25. -->

# Assertion Audit Log

**Skill**: taskrouter
**Audit date**: 2026-03-25
**Auditor**: Claude + MC

## Summary

| Verdict | Count |
|---------|-------|
| CONFIRMED | 56 |
| CORRECTED | 2 |
| QUALIFIED | 10 |
| REMOVED | 0 |
| **Total** | **68** |

## Corrections Applied

### C1: Task attributes in list
- **Original text**: Docs say "attributes returns null in list responses"
- **Corrected text**: Skill gotcha states attributes ARE present in list responses contrary to docs
- **Why**: REST API list endpoint returned full attributes for both tasks.

### C2: MCP task update gap
- **Original text**: Listed as "update task" in MCP gaps without specificity
- **Corrected text**: Clarified the specific gap: no MCP tool to change task `assignmentStatus` (complete/cancel/wrapping).

## Qualifications Applied

- **Q1-Q4**: Voice-dependent instructions — Conference, dequeue, call, redirect require actual voice calls. Accept was live-verified; others from docs.
- **Q5**: multiTaskEnabled irreversibility — Docs confirm; not live-tested.
- **Q6-Q7**: Task update and callback constraints — Docs confirm both.
- **Q8-Q9**: Auto-cancel and pagination — Would require 1000 rejection cycles or specific pagination testing.
- **Q10**: Channel capacity — Would require multitasking configuration.
