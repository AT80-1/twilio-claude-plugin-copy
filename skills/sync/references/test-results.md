---
name: test-results
description: Live test evidence for Sync skill assertions with SID references.
---

<!-- ABOUTME: Live test evidence for Sync skill assertions. Every behavioral claim traces back to a SID. -->
<!-- ABOUTME: Use when verifying skill claims or reproducing test scenarios. -->

# Sync Skill — Live Test Results

Evidence date: 2026-03-25. All tests run via MCP tools and direct REST API (`curl`). Resources cleaned up after testing.

## Test 1: Document CRUD

| Operation | Result |
|-----------|--------|
| Create with uniqueName + TTL (300s) | `dateExpires` set 5min out |
| Create without uniqueName | Works, `unique_name: null`, `created_by: "system"` |
| Create with empty `{}` data | Valid, revision "0" |
| Fetch by uniqueName | Returns full document with data, revision, dates |
| Fetch nonexistent | Error 20404 "resource was not found" (NOT 54100) |
| Update (full replace test) | `{theme,version,nested}` updated to `{theme:"light"}` → result: `{theme:"light"}` only. **Confirmed full replace.** |
| Update increments revision | "0" → "1" after update |
| Delete by uniqueName | Success |
| Duplicate uniqueName | Error 54301 "Unique name already exists" (HTTP 409) |

## Test 2: TTL Enforcement

| Test | Setup | Result |
|------|-------|--------|
| Short TTL expiry | Document with `ttl=10` | Gone within 15 seconds |
| Empty container TTL | List with `ttl=30` | Expired before 30s mark |
| `dateExpires` accuracy | Document `ttl=10` | `dateExpires` is exact +10s from creation |
| Item without `itemTtl` | Added to list with parent TTL | `dateExpires: null` on item |

## Test 3: collectionTtl Reset

| Step | State |
|------|-------|
| Create list with `ttl=60` | `dateExpires` set 60s out |
| Wait 30 seconds | List should expire in ~30s |
| Add item with `collectionTtl=120` | Item `dateExpires: null` (no itemTtl) |
| Check parent list | `dateExpires` **reset to item_time + 120s** |

**Confirmed**: `collectionTtl` on item write resets parent's expiration to `now + collectionTtl`, regardless of original TTL.

## Test 4: List Index Behavior

| Operation | Index Assigned |
|-----------|---------------|
| Add item 1 | 0 |
| Add item 2 | 1 |
| Add item 3 | 2 |
| Delete index 1 | — |
| Add item 4 | **4** (skipped 3) |
| List all (asc) | Returns indices 0, 2, 4 |
| List all (desc) | Returns indices 4, 2, 0 |
| List from=2 (asc) | Returns indices 2, 4 (inclusive) |

**Confirmed**: Indices are non-contiguous, never reused, new indices may skip values.

## Test 5: Map Key Characters

| Key | Create | Get | Update | Remove |
|-----|--------|-----|--------|--------|
| `simple-key` | OK | OK | OK (full replace confirmed) | OK |
| `key/with/slashes` | OK | FAIL "Parameter 'key' is not valid" | FAIL | FAIL |
| `key.with.dots` | OK | OK | not tested | not tested |
| `emojicafenaive` (unicode) | OK | OK | not tested | not tested |

**Confirmed**: Slashes break individual access. Dots and Unicode work.

## Test 6: Map Upsert Behavior

| Operation | Result |
|-----------|--------|
| `add_sync_map_item` with existing key | Error 54208 (HTTP 409) |
| `update_sync_map_item` on existing key | Success, full replace |
| `update_sync_map_item` on nonexistent key | Error 20404 |

**Confirmed**: Add is NOT upsert. Must use update for existing keys.

## Test 7: Conditional Updates (If-Match)

| If-Match Value | Result |
|----------------|--------|
| `0` (wrong) | Error 54103 (HTTP 412) |
| `1` (correct) | Success, revision incremented to "2" |
| Omitted | Success, unconditional write (last-write-wins) |

**Confirmed**: `If-Match` header works for optimistic concurrency. MCP tools always omit it.

## Test 8: Error Code Verification

| Trigger | Code | HTTP | Message |
|---------|------|------|---------|
| Fetch nonexistent document | 20404 | 404 | "The requested resource ... was not found" |
| Fetch nonexistent list | 20404 | 404 | Same |
| Fetch nonexistent map item | 20404 | 404 | Same |
| Create with >16 KiB data | 54006 | 413 | "Request entity too large" |
| Invalid JSON in Data | 54008 | 400 | "Invalid request body" |
| Duplicate uniqueName | 54301 | 409 | "Unique name already exists" |
| Duplicate map key | 54208 | 409 | "An Item with given key already exists" |
| Wrong If-Match revision | 54103 | 412 | "revision does not match" |
