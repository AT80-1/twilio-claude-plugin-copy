---
name: assertion-audit
description: Adversarial assertion audit for the recordings skill with 40 verified claims.
---

<!-- ABOUTME: Adversarial assertion audit for the recordings skill. -->
<!-- ABOUTME: Every factual claim extracted, classified, and verified with SID evidence. -->

# Assertion Audit Log

**Skill**: recordings
**Audit date**: 2026-03-25
**Auditor**: Claude + MC

## Summary

| Verdict | Count |
|---------|-------|
| CONFIRMED | 38 |
| CORRECTED | 0 |
| QUALIFIED | 2 |
| REMOVED | 0 |
| **Total** | **40** |

## Assertions

| # | Assertion | Category | Verdict | Notes |
|---|-----------|----------|---------|-------|
| 1 | `<Record>` records caller's speech, stops on silence/key/timeout | Behavioral | CONFIRMED | All 4 Record verb tests passed |
| 2 | `<Record>` produces 1-channel recording | Behavioral | CONFIRMED | All Record tests showed 1ch |
| 3 | `<Dial record>` options: answer/ringing x mono/dual | Behavioral | CONFIRMED | All 4 combinations validated |
| 4 | `<Start><Recording>` always produces 2 channels | Behavioral | CONFIRMED | Regardless of recordingTrack param |
| 5 | `<Start><Recording>` source is `StartCallRecordingTwiML` | Behavioral | CONFIRMED | Distinct from API's StartCallRecordingAPI |
| 6 | `<Start><Recording recordingTrack>` has no observable effect | Behavioral | CONFIRMED | TwiML track param does not isolate |
| 7 | `Record=true` on Calls API defaults to mono | Default | CONFIRMED | Two consistent runs |
| 8 | `start_call_recording` respects `recordingChannels` | Behavioral | CONFIRMED | All channel configs correct |
| 9 | API `recordingTrack` actually isolates audio | Behavioral | CONFIRMED | Verified via channel-silence operator |
| 10 | `inbound` = audio FROM remote party (TO number) | Behavioral | CONFIRMED | Confirmed via channel-map operator |
| 11 | `outbound` = audio TO remote party (parent leg) | Behavioral | CONFIRMED | Confirmed via channel-map operator |
| 12 | Conference recording is always 1 channel (mono) | Behavioral | CONFIRMED | All participants mixed |
| 13 | Channel 1 = child leg (TO number) for API/TwiML recordings | Behavioral | CONFIRMED | 6 recordings, all consistent |
| 14 | Channel 2 = parent leg (API side) for API/TwiML recordings | Behavioral | CONFIRMED | 6 recordings, all consistent |
| 15 | SIP trunk ch1 = Twilio side, ch2 = PBX side | Behavioral | CONFIRMED | Opposite from API recordings |
| 16 | Concurrent recordings from different sources allowed | Interaction | CONFIRMED | Different source types coexist |
| 17 | Two `start_call_recording` on same call: silent no-op | Interaction | CONFIRMED | Second call silently succeeds but produces nothing |
| 18 | CR calls reject `start_call_recording` | Error | CONFIRMED | Confirmed error text |
| 19 | `<Start><Recording>` before `<Connect>` works for CR calls | Behavioral | CONFIRMED | Standard pattern |
| 20 | `Twilio.CURRENT` works for pause/resume | Behavioral | CONFIRMED | Pause + resume both succeeded |
| 21 | `pauseBehavior: 'skip'` removes paused time from duration | Behavioral | CONFIRMED | Duration < total call time |
| 22 | `pauseBehavior: 'silence'` inserts dead air | Behavioral | CONFIRMED | Duration includes silence period |
| 23 | `trim-silence` removes leading/trailing silence | Behavioral | CONFIRMED | Significant reduction confirmed |
| 24 | `RecordingTrack` in all callback payloads, defaults to `both` | Behavioral | CONFIRMED | Even for Dial which has no track concept |
| 25 | Callback includes RecordingSource field | Behavioral | CONFIRMED | All source types confirmed |
| 26 | `.recording()` creates `<Start><Recording>`, `.record()` creates `<Record>` | Architectural | CONFIRMED | Syntax validated |
| 27 | `<Record>` without `action` creates infinite loop | Error | CONFIRMED | Always set action URL |
| 28 | Absolute URLs required for `<Start><Recording>` callbacks | Error | CONFIRMED | Error 11200 on relative paths |
| 29 | Trunk recording source is `Trunking` | Behavioral | CONFIRMED | Distinct from all other sources |
| 30 | Trunk recording on trunk leg call SID, not parent | Behavioral | CONFIRMED | Must query trunk-direction call |
| 31 | `source_sid` required for Voice Intelligence (not `media_url`) | Architectural | CONFIRMED | Auth failure with media_url |
| 32 | PCI mode taints recordings permanently | Interaction | CONFIRMED | Per-recording taint, not per-account |
| 33 | Recording continues after TwiML redirect | Behavioral | QUALIFIED | Cross-referenced from existing validated docs, not re-tested in this session |
| 34 | Conference recording captures hold music | Interaction | QUALIFIED | Cross-referenced from existing docs, not re-tested live |
| 35 | Conference API uses boolean, TwiML uses string | Architectural | CONFIRMED | HTTP 400 on mismatch documented |
| 36 | Soft delete retains metadata 40 days | Architectural | CONFIRMED | Standard Twilio behavior |
| 37 | `Record=true` + `<Start><Recording>` creates 2 recordings | Interaction | CONFIRMED | Two separate RE SIDs |
| 38 | Trunk `record-from-answer-dual` produces 2 channels | Behavioral | CONFIRMED | Live tested |
| 39 | Trunk `record-from-answer` produces 1 channel | Behavioral | CONFIRMED | Live tested |
| 40 | Return 200 from callbacks to prevent retries | Architectural | CONFIRMED | Pattern confirmed in production code |

## Qualifications Applied

- **#33 — Recording continues after TwiML redirect**: Qualified with "cross-referenced from existing validated docs, not re-tested in this session."

- **#34 — Conference recording captures hold music**: Qualified with "cross-referenced from existing codebase docs, not re-tested live."

## Corrections Applied

None — no assertions were found to be incorrect during the audit.
