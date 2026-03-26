---
name: test-results
description: Live test evidence for Proxy skill assertions with SID references.
---

<!-- ABOUTME: Live test evidence for Proxy skill assertions. Every behavioral claim traces back to a SID. -->
<!-- ABOUTME: Use when verifying skill claims or reproducing test scenarios. -->

# Proxy Skill — Live Test Results

Evidence date: 2026-03-25. All tests via direct REST API (`curl`). Resources cleaned up after testing.

## Test 1: Service CRUD

| Operation | Result |
|-----------|--------|
| Create with all params | OK: uniqueName, geoMatchLevel=country, numberSelectionBehavior=avoid-sticky, defaultTtl=300 |
| Delete with active sessions | HTTP 204 — **cascading delete, no warning** |

## Test 2: Number Pool

| Operation | Result |
|-----------|--------|
| Add number by SID | OK: capabilities shown, inUse=0, isReserved=false |
| Add duplicate number | Error 80104 "PhoneNumber already added to Service" |
| Add as reserved | OK: isReserved=true, inUse=0 |
| Webhook overwrite on add | voiceUrl/smsUrl changed from empty to demo.twilio.com |
| Webhook after service delete | Reverted to demo.twilio.com defaults, NOT original values |

## Test 3: Session Lifecycle

| Operation | Result |
|-----------|--------|
| Create with TTL=600 | status=open, dateExpiry=null, dateStarted=null |
| Create with dateExpiry + TTL | Both stored: ttl=600, dateExpiry set |
| Status with 2 participants (no interaction) | Remains `open`, not `in-progress` |
| Close (Status=closed) | closedReason="api", dateEnded set, dateStarted still null |
| Reopen to `open` | Error 80608: "choose In Progress" |
| Reopen to `in-progress` | Success: closedReason=null, dateEnded=null, participants preserved |
| Duplicate uniqueName | Error 80603 "Session UniqueName must be unique" |
| List interactions (no comms) | Empty array, 0 interactions |

## Test 4: Participants

| Operation | Result |
|-----------|--------|
| Add real number | OK: auto-assigned proxy from pool |
| Add second participant | OK: same proxy number as first |
| Add fake number (+15551234567) | Error 80404 "not valid, reachable identity" |
| Add 3rd participant | Error 80609 "max 2 participants" |
| Add duplicate identifier | Error 80103 "already added to Session" |
| Participants after close+reopen | Both preserved with same proxy assignments |

## Test 5: Reserved Number Behavior

| Operation | Result |
|-----------|--------|
| Auto-assign with only reserved numbers | Error 80207 "only matching candidates are marked as Reserved" |
| Explicit assign via ProxyIdentifier | Error "Unmanaged Proxy Identifier not found" |
| Explicit assign via ProxyIdentifierSid | Error 80207 — same as auto-assign |

**Finding**: Reserved numbers cannot be explicitly assigned in practice, contradicting documentation. Workaround: keep numbers unreserved for active use.

## Test 6: Error Code Summary

| Code | HTTP | Verified Message |
|------|------|-----------------|
| 80103 | 400 | Participant has already been added to Session |
| 80104 | 400 | PhoneNumber has already been added to Service |
| 80207 | 400 | This Service has no compatible Proxy numbers for this Participant |
| 80404 | 400 | Participant identifier does not appear to be a valid, reachable identity |
| 80603 | 400 | Session UniqueName must be unique |
| 80608 | 400 | Session status change not supported. To re-open, choose In Progress |
| 80609 | 400 | A Session may have at most 2 participants |
