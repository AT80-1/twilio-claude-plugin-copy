---
name: assertion-audit
description: Adversarial assertion audit for the Twilio CLI skill with 38 verified claims.
---

<!-- ABOUTME: Adversarial assertion audit for the Twilio CLI skill. Every factual claim pressure-tested. -->
<!-- ABOUTME: Proves provenance chain for all behavioral claims. 38 assertions extracted, audited 2026-03-25. -->

# Assertion Audit Log

**Skill**: twilio-cli
**Audit date**: 2026-03-25
**Auditor**: Claude + MC

## Summary

| Verdict | Count |
|---------|-------|
| CONFIRMED | 30 |
| CORRECTED | 0 |
| QUALIFIED | 8 |
| REMOVED | 0 |
| **Total** | **38** |

## Qualifications Applied

- **Q1**: Env var management — MCP has partial coverage via `create_variable`/`update_variable`.
- **Q2**: Phone number release — MCP `release_phone_number` tool also exists.
- **Q3**: `--profile` on `serverless:*` — Based on operational experience, not systematic testing.
- **Q4**: Sync item-level CLI — Not exhaustively tested.
- **Q5-Q7**: Console-only operations — Trust Hub, Flex, and Studio may have partial API coverage.
- **Q8**: CLI-only simplified rule — `phone-numbers:buy` is also CLI-recommended due to interactive nature.
