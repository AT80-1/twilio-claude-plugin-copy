---
name: assertion-audit
description: Adversarial assertion audit for the Sync skill with 63 verified claims.
---

<!-- ABOUTME: Adversarial assertion audit for the Sync skill. Every factual claim pressure-tested with evidence. -->
<!-- ABOUTME: Proves provenance chain for all behavioral claims. 63 assertions extracted, audited 2026-03-25. -->

# Assertion Audit Log

**Skill**: sync
**Audit date**: 2026-03-25
**Auditor**: Claude + MC

## Summary

| Verdict | Count |
|---------|-------|
| CONFIRMED | 55 |
| CORRECTED | 3 |
| QUALIFIED | 5 |
| REMOVED | 0 |
| **Total** | **63** |

## Corrections Applied

### C1: Gotcha 9 — Empty container TTL timing
- **Original text**: "A 30-second TTL empty list expired before the 30s mark."
- **Corrected text**: "A 30-second TTL empty list was already expired when checked at ~25 seconds."
- **Why**: The exact timing was uncertain — softened to avoid implying enforcement is faster than nominal TTL.

### C2: Gotcha 11 — TTL alias MCP nuance
- **Original text**: "On containers, `ttl` aliases `collectionTtl`. On items, it aliases `itemTtl`."
- **Corrected text**: Added clarification that MCP tools expose only `ttl`, so the alias behavior is the default path via MCP.

### C3: MCP create_document uniqueName requirement
- **Original text**: MCP tool table listed `uniqueName` as required.
- **Corrected text**: REST API does not require uniqueName. The MCP tool enforces it as required.
- **Why**: MCP schema has `required: ["uniqueName", "data"]` but the REST API allows omitting uniqueName.

## Qualifications Applied

- **Q1**: Stream assertions (A4) — Not live-tested (no MCP tools). Docs-sourced.
- **Q2**: Webhook events (A9) — Requires `webhooksFromRestEnabled=true` for REST/MCP writes.
- **Q3**: Map items order/from params (A13) — REST API supports these; MCP does not expose them.
- **Q4**: Stream 30 msg/s rate (A20) — Rate varies with message size.
- **Q5**: Write rate degradation thresholds (A26) — Burst windows allow temporary spikes.
