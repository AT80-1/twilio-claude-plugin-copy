---
name: test-results
description: Live test evidence for TaskRouter skill assertions with SID references.
---

<!-- ABOUTME: Live test evidence for TaskRouter skill assertions. Every behavioral claim traces back to a SID. -->
<!-- ABOUTME: Use when verifying skill claims or reproducing test scenarios. -->

# TaskRouter Skill — Live Test Results

Evidence date: 2026-03-25. Workspace deleted after testing.

## Test 1: FIFO Template

| What was created | Details |
|-----------------|---------|
| Activities | 3: Offline (available=false), Available (available=true), Unavailable (available=false) |
| Task Queue | 1: "Sample Queue", targetWorkers="1==1", FIFO |
| Workflow | 1: "Default Fifo Workflow", 120s timeout, no callback URL |
| Default activity | Offline |
| Timeout activity | Offline — same as default |

## Test 2: Worker Creation

| Test | Result |
|------|--------|
| Create with Available activity | available=true, activityName="Available" |
| Create with Offline activity | available=false, activityName="Offline" |
| Omit activitySid | Gets workspace defaultActivitySid (Offline) |
| Attributes JSON with arrays+numbers | Stored and returned correctly |
| Duplicate friendlyName "Alice" | Error 20001 "Worker with the same friendly name already exists" |
| Hyphen in attribute name | Accepted: `{"skill-level": 5}` stored OK |

## Test 3: Expression Edge Cases

| Expression | Context | Result |
|-----------|---------|--------|
| `skills HAS "support"` | Queue create | OK — matches workers with support in skills array |
| `level HAS "support"` | Queue create | **Accepted** — no validation error. Will never match. |
| `skill-level > 3` | Queue create | **Error 20001**: "extraneous input 'evel' expecting OPERATOR" |

## Test 4: Task Routing & Priority

| Test | Result |
|------|--------|
| Sales task (type="sales") | Routed to Sales Queue, reserved for Alice |
| Support task (type="support") | Routed to Support Queue, **0 reservations** (Alice already reserved, Bob offline) |
| Workflow target priority | Target `priority: 5` applied to task |
| Task priority from target `priority: 3` | Support task shows priority=3 |

## Test 5: Reservation Lifecycle

| Step | Observation |
|------|------------|
| Task created | assignmentStatus=pending |
| Worker matched | Reservation created, status=pending |
| 30s elapsed (no response) | Reservation status=timeout |
| Worker activity after timeout | **Moved from Available to Offline** (timeoutActivitySid) |
| Task status after timeout | **canceled**, reason="Task canceled on Workflow timeout" |
| Set worker back to Available | Immediately reserved for next pending task |
| Accept reservation | reservationStatus=accepted, task=assigned |
| Complete task | assignmentStatus=completed, reason="resolved" |

## Test 6: Activity Immutability

| Test | Result |
|------|--------|
| Update Offline activity: Available=true | HTTP 200 returned — **no error** — but available stayed false. Silent no-op. |

## Test 7: Queue Statistics

| Field | Sales Queue | Support Queue |
|-------|------------|---------------|
| totalAvailableWorkers | 1 | 1 |
| totalEligibleWorkers | 1 | 2 |
| totalTasks | 1 | 1 |
| longestTaskWaitingAge | 0 | 11 |
| tasksByStatus.reserved | 1 | 0 |
| tasksByStatus.pending | 0 | 1 |
| activityStatistics | Per-activity worker count breakdown | Per-activity worker count breakdown |

## Test 8: validate_task Event Timeline

Full event history for completed task:

| Event | Type | Timestamp |
|-------|------|-----------|
| 1 | workflow.entered | 04:00:56 |
| 2 | task-queue.entered | 04:00:56 |
| 3 | task.created | 04:00:56 |
| 4 | workflow.target-matched | 04:00:56 |
| 5 | reservation.created | 04:01:16 |
| 6 | reservation.accepted | 04:01:26 |
| 7 | task.completed | 04:06:18 |
| 8 | reservation.completed | 04:06:18 |
| 9 | task.updated | 04:06:18 |

## Test 9: Task Attributes in List

| Endpoint | Attributes Present? |
|----------|-------------------|
| REST `GET /Tasks` | **Yes** — full attributes returned (contradicts docs) |
| MCP `list_tasks` | Yes — attributes included |
