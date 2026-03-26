---
name: test-results
description: Validation matrix results for Twilio recording methods with live test evidence.
---

<!-- ABOUTME: Validation matrix results for Twilio recording methods. -->
<!-- ABOUTME: Live-tested 2026-03-24 with call SIDs for evidence. -->

# Recording Validation Matrix — Test Results

All tests run 2026-03-24. Deterministic agents (NATO phonetic phrases, no LLM) used for all tests.

## Summary

| Stat | Value |
|------|-------|
| Total tests run | 47 (Phases A-H + transcript validation) |
| Passed | 44 |
| Failed | 3 (Pause/Resume — "not eligible for recording") |
| Recording methods validated | 14 of 17 (SIP trunk deferred) |
| Transcript analysis | **COMPLETE** — 6 recordings transcribed with 5 Language Operators |

## Recording Metadata Results

### Source Field Discovery

| Recording Method | Observed `source` Value |
|-----------------|------------------------|
| `<Record>` verb | `RecordVerb` |
| `<Dial record="...">` | `DialVerb` |
| `<Start><Recording>` | **`StartCallRecordingTwiML`** |
| Calls API `Record=true` | `OutboundAPI` |
| `start_call_recording` API | `StartCallRecordingAPI` |
| Conference `record` attribute | `Conference` |

**Key discovery**: `<Start><Recording>` reports source as `StartCallRecordingTwiML`, NOT `StartCallRecordingAPI`. These are distinct source values that distinguish TwiML-initiated vs API-initiated recordings.

### Channel Count Matrix

| Method | Expected | Observed | Notes |
|--------|----------|----------|-------|
| R1 `<Record>` | 1 | **1** | Single channel, caller audio only |
| R2 `<Dial record-from-answer>` | 1 | **1** | Mono, both parties mixed |
| R3 `<Dial record-from-answer-dual>` | 2 | **2** | Dual channel confirmed |
| R4 `<Dial record-from-ringing>` | 1 | **1** | Mono, includes ringback |
| R5 `<Dial record-from-ringing-dual>` | 2 | **2** | Dual channel confirmed |
| R6 `<Start><Recording> track=both` | 1 (expected) | **2** | **SURPRISE: always 2ch** |
| R7 `<Start><Recording> track=inbound` | 1 (expected) | **2** | **SURPRISE: always 2ch** |
| R8 `<Start><Recording> track=outbound` | 1 (expected) | **2** | **SURPRISE: always 2ch** |
| R9 Calls API `Record=true` | TBD | **1** | **Mono by default** |
| R10 API `channels=mono, track=both` | 1 | **1** | Confirmed |
| R11 API `channels=dual, track=both` | 2 | **2** | Confirmed |
| R12 API `channels=mono, track=inbound` | 1 | **1** | Confirmed |
| R13 API `channels=mono, track=outbound` | 1 | **1** | Confirmed |
| R14 Conference TwiML `record` | 1 | **1** | Mono, all participants mixed |

**Major finding**: `<Start><Recording>` ALWAYS produces 2-channel recordings regardless of the `recordingTrack` parameter. The `recordingTrack` parameter controls which audio is captured (one channel may be silent), but both channels are always written. This is different from the `start_call_recording` API which respects `recordingChannels`.

### Concurrent Recording Results (Phase E)

| Test | Method Combination | Recordings Created | Sources |
|------|-------------------|-------------------|---------|
| E1 | `<Dial record>` + API recording | **2** | DialVerb (2ch, 13s) + StartCallRecordingAPI (1ch, 9s) |
| E2 | API `Record=true` + API `start_call_recording` | **2** | OutboundAPI (1ch, 16s) + StartCallRecordingAPI (2ch, 11s) |
| E3 | Two API `start_call_recording` | **1** | Second succeeded silently (no error), only 1 recording |
| E4 | TwiML `<Start><Recording>` + API recording | **2** | StartCallRecordingTwiML (2ch, 13s) + StartCallRecordingAPI (2ch, 9s) |

**Key findings**:
- Concurrent recordings from different sources are allowed and produce separate RE SIDs
- Two API recordings via `start_call_recording` do NOT error — the second call appears to succeed but only one recording is produced
- Each concurrent recording has its own source, channels, and duration

### Pause/Resume Results (Phase F)

**All 3 tests FAILED** with error: "Requested resource is not eligible for recording"

This error occurs when trying to start an API recording on a call that's connected via ConversationRelay (`<Connect><ConversationRelay>`). The `start_call_recording` API cannot record calls in the `<Connect>` state.

**Workaround**: Use `<Start><Recording>` BEFORE `<Connect>` (as the standard pattern), or use `Record=true` on the Calls API at call creation time.

### Callback Payload Validation (Phase H)

All callback payloads confirmed to include:

| Field | Present | Example Value |
|-------|---------|---------------|
| `AccountSid` | Yes | AC... |
| `CallSid` | Yes | CA... |
| `RecordingSid` | Yes | RE... |
| `RecordingUrl` | Yes | Without extension |
| `RecordingStatus` | Yes | `completed` |
| `RecordingDuration` | Yes | Seconds as string |
| `RecordingChannels` | Yes | `1` or `2` |
| `RecordingSource` | Yes | See source table above |
| `RecordingStartTime` | Yes | RFC 2822 format |
| `RecordingTrack` | Yes | `both` (even for non-track methods) |
| `ErrorCode` | Yes | `0` for success |

**New discovery**: `RecordingTrack` is included in ALL callback payloads, defaulting to `both` even when the method doesn't support track selection (e.g., `<Dial record>`).

## Transcript + Operator Validation

Initial transcripts were blocked by PCI mode on the account. After PCI disable + fresh recordings, all transcripts completed in ~10 seconds with 5 Language Operators firing.

**Root cause of earlier transcript stalls**: PCI mode prevents Voice Intelligence from processing recordings. Recordings created while PCI is active are permanently untranscribable even after PCI is disabled. Only fresh recordings (created post-PCI-disable) can be transcribed.

### Channel Assignment — THE Definitive Answer

Validated by `channel-map` operator across 6 recording methods. **Consistent result across every method**:

**Channel assignment rule**:
- **Channel 1 = child leg / TO number / inbound audio** (the party being called)
- **Channel 2 = parent leg / API-initiated side / outbound audio** (the caller/initiator)

This maps to the Voice Intelligence participant labels:
- `channel_participant: 1` ("caller") = the TO number's audio
- `channel_participant: 2` ("agent") = the API-initiated side's audio

### Track Isolation — `recordingTrack` Does NOT Silence Channels

**Confirmed**: `<Start><Recording recordingTrack="inbound|outbound">` does NOT silence the other channel. Both channels always contain audio regardless of the `recordingTrack` parameter. Combined with the finding that `<Start><Recording>` always produces 2 channels, the `recordingTrack` parameter on the TwiML verb appears to have no observable effect on the recording output.

## Deferred Tests — Completed

### Pause/Resume (API Recording)

Pause/Resume does NOT work on ConversationRelay-connected calls ("not eligible for recording"). Works on API-started recordings on non-CR calls.

| Test | pauseBehavior | Duration | Expected | Finding |
|------|--------------|----------|----------|---------|
| D1 | `skip` | **7s** | ~6s (3+3, skip 3) | Skip removes paused time from recording |
| D2 | `silence` | **8s** | ~9s (3+3silence+3) | Silence inserts dead air, included in duration |

**`Twilio.CURRENT` confirmed working** — `client.calls(sid).recordings('Twilio.CURRENT').update()` successfully pauses and resumes without knowing the RE SID.

### API `recordingTrack` — Actually Isolates (Unlike TwiML)

The API's `start_call_recording` with `recordingTrack` parameter DOES isolate audio. The TwiML `<Start><Recording recordingTrack>` does NOT. Critical distinction.

| Test | Track | Finding |
|------|-------|---------|
| D4 API `inbound` | inbound | **Inbound = child leg audio (TO number)** |
| D5 API `outbound` | outbound | **Outbound = parent leg audio (API side)** |

**Key insight**: "inbound" means audio arriving at Twilio FROM the remote party (the TO number). "Outbound" means audio sent BY Twilio TO the remote party (the parent leg's audio/TTS).

### SIP Trunk Recording — COMPLETE

| Mode | Channels | Duration | Source |
|------|----------|----------|--------|
| `record-from-answer-dual` | **2** | 12s | `Trunking` |
| `record-from-answer` (mono) | **1** | 8s | `Trunking` |

**Trunk recording findings**:
- Source is `Trunking` (distinct from all other sources)
- Call direction is `trunking-originating`
- Recording SID is on the **trunk leg's call SID**, not the parent API call. You must find the trunk call to list its recordings.
- Dual-channel trunk recording: ch1 = Twilio/originating side (TTS/TwiML audio), ch2 = SIP/terminating side (PBX audio)
- Channel assignment for trunk recordings is **opposite** from API recordings — ch1 = the originator's audio, ch2 = the remote party.

## Questions Answered

1. **`<Start><Recording>` source**: `StartCallRecordingTwiML` (distinct from API's `StartCallRecordingAPI`)
2. **`<Start><Recording>` channels**: Always 2, regardless of `recordingTrack` parameter
3. **Calls API `Record=true` channels**: 1 (mono) by default
4. **Concurrent recordings**: Allowed from different sources, produce separate RE SIDs
5. **Two API recordings on same call**: Second silently succeeds but only one recording produced
6. **Callback fields**: All methods include RecordingTrack, RecordingSource, RecordingChannels
7. **Pause/Resume on ConversationRelay**: NOT supported — "not eligible for recording" error
8. **`trim-silence`**: Confirmed working — reduced 10s recording to 5s
9. **Channel assignment**: Channel 1 = child leg (TO number), Channel 2 = parent leg (API side). Consistent across ALL methods.
10. **`recordingTrack` on `<Start><Recording>`**: Has no observable effect — both channels always have audio, recording is always 2 channels.
11. **PCI mode blocks Voice Intelligence**: Recordings created under PCI mode are permanently untranscribable.
12. **`Twilio.CURRENT`**: Works for pause/resume without knowing RE SID.
13. **API `recordingTrack` isolates audio**: `inbound` = child leg only, `outbound` = parent leg only. Unlike TwiML which does NOT isolate.
14. **Pause `skip` vs `silence`**: Skip removes paused time (shorter duration). Silence inserts dead air (same duration as elapsed time).
15. **SIP trunk recording**: Source is `Trunking`, records on trunk leg call SID (not parent). Dual-channel: ch1=originator, ch2=remote (opposite from API recordings).
16. **Channel assignment differs by recording source**: API: ch1=child, ch2=parent. Trunk: ch1=originator(Twilio), ch2=terminator(PBX). Not universal — depends on how the call was established.
